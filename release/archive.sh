#!/bin/sh
set -o nounset

archive_cleanup () {
    cd "$scriptdir" || exit
    rm -rf tmp/
}

archive () {
    local fname
    local exe7za="C:/Users/$USERNAME/AppData/Local/Programs/jai/7za.exe"
    local description toplevel
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
            "$exe7za" a -mx9 "../$fname.7z" "$fname" || return
        ) || return
        "$exe7za" a -mx9 "$name.7z" * || return
        cp "../../$name.sfx" . || return
        cmd //c "copy /b $name.sfx + $name.7z $(cygpath -w "../../$(basename $PWD).exe")" || return
    ) || return
}

print_adoc () {
    local asciidoctor_pdf="C:/Ruby32-x64/bin/asciidoctor-pdf"
    ls ../*.adoc 1>/dev/null 2>&1 || return 0
    "$asciidoctor_pdf" -a scripts=cjk \
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
