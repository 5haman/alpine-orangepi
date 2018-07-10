pkg_list() {
  curl --connect-timeout 120 --retry 5 -sSL "${baseurl}/main/${arch}" | grep '\.apk' \
  | grep -E "$(echo "${1}" | awk '{ print "\"" $0 "-[0-9]" }' | tr '\n' '|' | sed 's#|$##g')" \
  | awk -F 'href="' '{ print $2 }' | awk -F '">' '{ print $1 }' | grep -vE '\-doc|\-dev|acf\-'
}

apk_install() {
  curl --connect-timeout 120 --retry 5 -sSL "${baseurl}/main/${arch}/${1}" | tar -xzf - -C "${outdir}/${2}" 2>/dev/null
}
