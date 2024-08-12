# vim: set ft=make :

uid := `id -u`
shell := `grep :$(id -u): /etc/passwd | cut -d: -f7`
set shell := ["bash", "-cu"]

setup-gamescanner:
    sudo pacman -S --noconfirm python python-pip python-virtualenv
    python -m venv ./.venv
    source ./.venv/bin/activate
    pip install -r /usr/share/dev-work/snapshot-deps.txt
