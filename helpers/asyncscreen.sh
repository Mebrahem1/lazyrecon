#!/bin/bash -x
# kill used as workaround:
# https://bugs.chromium.org/p/chromium/issues/detail?id=1097565&can=2&q=component%3AInternals%3EHeadless

# 10 threads
THREADS=10
# to handle background PID of screenshot
declare -a PID_CHROMIUM

if [ -s "${1}/3-all-subdomain-live-scheme.txt" ]; then
  ITERATOR=0

  while read line; do
    echo
    echo "[screenshot] new target..."
    echo $line

      SCOPE=$(echo "$line" | grep -oriahE "(([[:alpha:][:digit:]-]+\.)+)?[[:alpha:][:digit:]-]+\.[[:alpha:]]{2,5}([:][[:digit:]]{2,4})?" | sed "s/:/_/;s/[.]/_/g")
      chromium --headless --disable-gpu --no-sandbox --window-size=1280,720 --screenshot="${1}/screenshots/${SCOPE}.png" $line &

        PID_CHROMIUM[$ITERATOR]=$!
        echo "PID_CHROMIUM=${PID_CHROMIUM[@]}"
        ITERATOR=$((ITERATOR+1))

        if [ $((ITERATOR % THREADS)) -eq 0 ]; then
          sleep 6
            for PID_TMP in "${!PID_CHROMIUM[@]}"; do
                echo "#PID_CHROMIUM=${#PID_CHROMIUM[@]}"
                echo "killing ${PID_CHROMIUM[$PID_TMP]}"
                kill -9 "${PID_CHROMIUM[$PID_TMP]}" || true
                unset PID_CHROMIUM[$PID_TMP]
            done
        fi

  done < "${1}/3-all-subdomain-live-scheme.txt"

  # remaining targets
  echo
  echo "[screenshot] remaining targets: ${#PID_CHROMIUM[@]}"
  sleep 6
  for PID_TMP in "${!PID_CHROMIUM[@]}"; do
      echo "killing ${PID_CHROMIUM[$PID_TMP]}"
      kill -9 "${PID_CHROMIUM[$PID_TMP]}" || true
      unset PID_CHROMIUM[$PID_TMP]
  done

  echo "[screenshot][debug] jobs -l:"
  jobs -l

fi