#!/usr/bin/env sh

CMD=$1
shift
IN_FILE=$1
shift
OUT_FILE=$1
shift
ERR_FILE=$1
shift

[ -e "${IN_FILE}" ]  || {
  echo ${IN_FILE}  does not exist >&2
  exit 1
}
[ -e "${OUT_FILE}" ] || {
  echo ${OUT_FILE} does not exist >&2
  exit 2
}
[ -e "${ERR_FILE}" ] || {
  echo ${ERR_FILE} does not exist >&2
  exit 3
}
[ -x "${CMD}" ] || {
  echo "$(basename ${CMD}) not yet implemented" >&2
  exit 4
} 


timeout 10 ${CMD} < ${IN_FILE} > ${OUT_FILE}.IS 2> ${ERR_FILE}.IS

diff ${OUT_FILE} ${OUT_FILE}.IS > /dev/null
out_result=$?

echo "Last 10 lines of STDOUT DIFF lines marked with - are missing one with + are excessive"
diff -u  ${OUT_FILE} ${OUT_FILE}.IS | tail +4 | tail -n 10 | sed s/^/">>>"/ | sed s/$/'\\n'/

rm -f ${OUT_FILE}.IS

diff ${ERR_FILE} ${ERR_FILE}.IS > /dev/null
err_result=$?

echo "Last 10 lines of STDERR DIFF lines marked with - are missing one with + are excessive"
diff -u  ${ERR_FILE} ${ERR_FILE}.IS | tail +4 | tail -n 10 | sed s/^/">>>"/ | sed s/$/'\\n'/

rm -f ${ERR_FILE}.IS

[ 0 -eq "${out_result}" ] || exit 5
[ 0 -eq "${err_result}" ] || exit 6 
