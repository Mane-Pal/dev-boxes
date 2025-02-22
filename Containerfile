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

FROM archaur AS devcontainer

# Copy the necessary files into the container
COPY ./toolbox-packages /toolbox-packages

# Update the package list, install packages
RUN pacman -Syu --noconfirm && \
    xargs -a /toolbox-packages pacman -S --noconfirm && \
    rm /toolbox-packages && \
    pacman -Scc --noconfirm

# Copy files after installing packages to benefit from Docker's caching
COPY ./files /

# Configure Locales and install bash-preexec
RUN pacman -S --noconfirm curl && \
    echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    echo 'LANG=en_GB.UTF-8' > /etc/locale.conf && \
    printf 'LANG=en_GB.UTF-8\nexport LANG\n' > /etc/profile.d/locale.sh && \
    printf 'LANG=en_GB.UTF-8\nexport LANG\nSTARSHIP_CONFIG=/etc/starship.toml\nexport STARSHIP_CONFIG\neval "$(atuin init zsh)"\neval "$(zoxide init zsh --cmd cd)"\neval "$(starship init zsh)"' >> /etc/zsh/zshrc && \
    rm -rf /tmp/*


