# vim: set ft=make :

uid := `id -u`
shell := `grep :$(id -u): /etc/passwd | cut -d: -f7`

setup-gamescanner:
    virtualenv venv
    source venv/bin/activate
    pip install -r gamescanner-terminal-deps.txt

