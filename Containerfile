FROM archlinux:latest AS archaur

LABEL com.github.containers.toolbox="true" \
      usage="This image is meant to be used with the Toolbox or Distrobox commands" \
      maintainer="madspaulsen@gmail.com"

# Install necessary dependencies and set up yay from AUR
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git && \
    useradd -m builduser && \
    echo "builduser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    su - builduser -c "git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm" && \
    rm -rf /home/builduser/yay


# Stage 2: Build the devcontainer with Arch Linux
FROM archaur AS devcontainer

# Copy the necessary files into the container
COPY ./toolbox-packages /toolbox-packages

# Update the package list, install packages
RUN pacman -Syu --noconfirm && \
    xargs -a /toolbox-packages pacman -S --noconfirm && \
    rm /toolbox-packages && \
    pacman -Scc --noconfirm

# copy files after install of packages for cache
COPY ./files /

# Configure Locales and install bash-preexec
RUN pacman -S --noconfirm curl && \
    echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_GB.UTF-8' > /etc/locale.conf && \
    printf 'LANG=en_GB.utf8\nexport LANG\n' > /etc/profile.d/locale.sh && \
    printf 'LANG=en_GB.utf8\nexport LANG\nSTARSHIP_CONFIG=/etc/starship.toml\nexport STARSHIP_CONFIG\neval "$(atuin init zsh)"\neval "$(zoxide init zsh --cmd cd)"\neval "$(starship init zsh)"' >> /etc/zsh/zshrc && \
    rm -rf /tmp/*


RUN   ln -fs /bin/sh /usr/bin/sh && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/docker && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/flatpak && \ 
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/podman && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/rpm-ostree && \
      ln -fs /usr/bin/distrobox-host-exec /usr/local/bin/transactional-update

