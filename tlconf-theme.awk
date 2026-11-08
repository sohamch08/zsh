# Uses the terminal ANSI palette and default foreground.
function repeat(s,n, out,i) {
    out=""; for(i=0;i<n;i++) out=out s
    return out
}
function row(k,v, label) {
    if(compact) {
        label=k==""?"":k ":"
        while(length(label)) {
            printf " %s│ %s%-*s%s │%s\n",edge,gold,room,substr(label,1,room),edge,off
            label=substr(label,room+1)
        }
        printf " %s│ %s%-*s%s │%s\n",edge,soft,room,v,edge,off
    } else {
        printf " %s│%s %-18s %s│%s %-*s %s│%s\n", edge,gold,k,edge,soft,room,v,edge,off
    }
    count++
}
function wrap(k,v, n,i,c,cut,part,first) {
    first=1
    do {
        if(length(v)<=room) { row(first?k:"",v); break }
        cut=room
        for(i=room;i>room/2;i--) {
            c=substr(v,i,1)
            if(c ~ /[\/,; ]/) { cut=i; break }
        }
        part=substr(v,1,cut)
        row(first?k:"",part)
        v=substr(v,cut+1)
        first=0
    } while(length(v))
}
function entry(k,v, n,a,i) {
    if(k=="PATH" || (v ~ /:\// && v !~ /[{}]/)) {
        n=split(v,a,":")
        for(i=1;i<=n;i++) wrap(i==1?k:"",a[i])
    } else wrap(k,v)
}
function closebox() {
    if(!opened) return
    if(!count) wrap("Status", "No entries")
    printf " %s╰%s╯%s\n",edge,repeat("─",inside),off
}
BEGIN {
    if(cols<=0) cols=80
    inside=cols-4
    compact=cols<60
    room=compact?inside-2:inside-23
    cyan="\033[1;34m"; gold="\033[33m"
    edge="\033[90m"; soft="\033[0;39m"; off="\033[0m"
}
/^=/ {
    closebox()
    sub(/^=+[[:space:]]*/,""); sub(/[[:space:]]*=+$/,"")
    heading=$0
    if(heading ~ /version information/) heading="TeX Live installation"
    if(heading ~ /executables found/) heading="Executables and PATH"
    if(heading ~ /active config/) heading="Configuration files"
    if(heading ~ /font map/) heading="Font maps"
    if(heading == "kpathsea variables") heading="Kpathsea variables"
    if(heading ~ /from environment only/) heading="Environment overrides"
    if(length(heading)>inside-3) heading=substr(heading,1,inside-3)
    printf "\n %s╭─ %s%s %s%s╮%s\n",edge,cyan,heading,edge,repeat("─",inside-length(heading)-3),off
    opened=1; count=0
    next
}
!opened {next}
/^tlmgr revision / {
    sub(/^tlmgr revision /, "")
    wrap("tlmgr revision", $0); next
}
/^tlmgr using installation:/ {
    sub(/^tlmgr using installation:[[:space:]]*/, "")
    wrap("Installation", $0); next
}
/^TeX Live / {
    sub(/^TeX Live /, "")
    wrap("TeX Live", $0); next
}
/^[[:alnum:]_.-]+[[:space:]]*[:=]/ {
    match($0,/^[[:alnum:]_.-]+/)
    k=substr($0,1,RLENGTH); v=substr($0,RLENGTH+1)
    sub(/^[[:space:]]*[:=][[:space:]]*/,"",v)
    entry(k,v)
    next
}
NF {wrap("",$0)}
END {closebox(); print ""}
