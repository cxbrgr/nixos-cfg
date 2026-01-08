default: switch

reload:
    nh os switch . --offline

switch:
    nh os switch .

switch-ii:
    qs -c $qsConfig kill 2>/dev/null || true
    nh os switch .
    (qs -c $qsConfig >/dev/null 2>&1 &)
    hyprctl reload && hyprctl reload

reload-ii:
    qs -c $qsConfig kill 2>/dev/null || true
    (qs -c $qsConfig >/dev/null 2>&1 &)
    hyprctl reload && hyprctl reload    

switch-dry:
    nh os switch --dry .    

build:
    nh os build .

update:
    nh os test . --update --diff always
