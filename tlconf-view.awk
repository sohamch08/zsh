# Lightweight preview renderer. Uses the terminal palette and one AWK process.
function repeat(s,n, out,i) {
    out=""; for(i=0;i<n;i++) out=out s
    return out
}
function row(k,v, label) {
    if(compact) {
        label=k==""?"":k ":"
        while(length(label)) {
            printf " %s%s%s\n",gold,substr(label,1,room),off
            label=substr(label,room+1)
        }
        printf " %s%s%s\n",soft,v,off
    } else {
        printf " %s%-18s%s │ %s%s%s\n",gold,k,edge,soft,v,off
    }
}
function wrap(k,v, i,c,cut,first) {
    first=1
    do {
        if(length(v)<=room) { row(first?k:"",v); break }
        cut=room
        for(i=room;i>room/2;i--) {
            c=substr(v,i,1)
            if(c ~ /[\/,; ]/) { cut=i; break }
        }
        row(first?k:"",substr(v,1,cut))
        v=substr(v,cut+1); first=0
    } while(length(v))
}
function entry(k,v, n,a,i) {
    if(k=="PATH" || (v ~ /:\// && v !~ /[{}]/)) {
        n=split(v,a,":")
        for(i=1;i<=n;i++) wrap(i==1?k:"",a[i])
    } else wrap(k,v)
}
function finish() {
    if(opened && !count) wrap("Status","No entries")
}
BEGIN {
    if(cols<=0) cols=80
    compact=cols<58
    room=compact?cols-2:cols-23
    if(room<1) room=1
    cyan="\033[1;34m"; gold="\033[33m"
    edge="\033[90m"; soft="\033[0;39m"; off="\033[0m"
}
/^=/ {source_section++}
selected && source_section!=selected {next}
/^=/ {
    finish()
    sub(/^=+[[:space:]]*/,""); sub(/[[:space:]]*=+$/,"")
    heading=$0
    if(heading ~ /version information/) heading="TeX Live installation"
    if(heading ~ /executables found/) heading="Executables and PATH"
    if(heading ~ /active config/) heading="Configuration files"
    if(heading ~ /font map/) heading="Font maps"
    if(heading == "kpathsea variables") heading="Kpathsea variables"
    if(heading ~ /from environment only/) heading="Environment overrides"
    if(opened) print ""
    printf " %s%s%s\n %s%s%s\n",cyan,substr(heading,1,cols-2),off,edge,repeat("─",cols-2),off
    opened=1; count=0
    next
}
!opened {next}
NF {count++}
/^tlmgr revision / {
    sub(/^tlmgr revision /,""); wrap("tlmgr revision",$0); next
}
/^tlmgr using installation:/ {
    sub(/^tlmgr using installation:[[:space:]]*/,""); wrap("Installation",$0); next
}
/^TeX Live / {
    sub(/^TeX Live /,""); wrap("TeX Live",$0); next
}
/^[[:alnum:]_.-]+[[:space:]]*[:=]/ {
    match($0,/^[[:alnum:]_.-]+/)
    k=substr($0,1,RLENGTH); v=substr($0,RLENGTH+1)
    sub(/^[[:space:]]*[:=][[:space:]]*/,"",v)
    entry(k,v); next
}
NF {wrap("",$0)}
END {finish()}
