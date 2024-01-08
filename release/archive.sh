#!/bin/sh
set -o nounset

archive_cleanup () {
    cd "$scriptdir" || exit
    rm -rf tmp/
}

archive () {
    local fname
    local exe7z
    local exe_from_7zip="C:/Program Files/7-Zip/7z.exe"
    local exe_from_jai="C:/Users/$USERNAME/AppData/Local/Programs/jai/7za.exe"
    local description toplevel
    if test -x "$exe_from_7zip"
    then
        exe7z=$exe_from_7zip
    elif test -x "$exe_from_jai"
    then
        exe7z=$exe_from_jai
    else
        >&2 printf "error: no 7-Zip excutable available\n"
        return 1
    fi
    printf "using %s\n" "$exe7z"
    rm -rf tmp/ || return
    mkdir tmp || return
    trap archive_cleanup INT TERM
    toplevel=$(git rev-parse --show-toplevel) || return
    description=$(git describe --always HEAD) || return
    description=${description#v}
    dirname=$(basename -- "$toplevel") || return
    fname="$dirname-$description"
    mkdir "tmp/$fname" || return
    (
        cd "$toplevel" || return
        jg ls-files \
            | grep -v '\(^\|/\).git\w\+$' \
            | grep -v '^release/' \
            | tr '\n' '\0' \
            | xargs -0 cp --parents -r -t "$scriptdir/tmp/$fname" \
            || return
    ) || return
    (
        set +o noglob
        cd "tmp/$fname" || return
        (
            cd .. || return
            tar -zcf "../$fname.tgz" "$fname" || return
            "$exe7z" a -mx9 "../$fname.7z" "$fname" || return
        ) || return
        "$exe7z" a -mx9 "$name.7z" * || return
        cp "../../$name.sfx" . || return
        cmd //c "copy /b $name.sfx + $name.7z $(cygpath -w "../../$(basename $PWD).exe")" || return
    ) || return
}

print_adoc () {
    ls ../*.adoc 1>/dev/null 2>&1 || return 0
    asciidoctor-pdf -a scripts=cjk \
        -a pdf-theme=cjk-theme.yml \
        -a pdf-fontsdir=$LOCALAPPDATA\\Microsoft\\Windows\\fonts,$WINDIR\\fonts \
        ../*.adoc \
        -D .
}

main () {
    local scriptdir name
    scriptdir=$(cd "$(dirname "$0")" && PWD) || exit
    name=$(basename -- "$(cd "$(git rev-parse --show-toplevel)" && PWD)") || exit
    cd "$scriptdir" || exit
    archive
    print_adoc
    archive_cleanup
}

main "$@"
