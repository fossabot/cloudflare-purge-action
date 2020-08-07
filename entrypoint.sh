#!/bin/sh

set -e


elif [ "$API_METHOD" -eq 2 ]; then
  HTTP_RESPONSE=$(curl -sS "https://api.cloudflare.com/client/v4/zones/${CLOUDFLARE_ZONE}/purge_cache" \
                      -H "Content-Type: application/json" \
                      -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
                      -w "HTTP_STATUS:%{http_code}" \
                      "$@")
fi


######## Format response for a pretty command line output. ########

# Store result and HTTP status code separately to appropriately throw CI errors.
# https://gist.github.com/maxcnunes/9f77afdc32df354883df
HTTP_BODY=$(echo "${HTTP_RESPONSE}" | sed -E 's/HTTP_STATUS\:[0-9]{3}$//')
HTTP_STATUS=$(echo "${HTTP_RESPONSE}" | tr -d '\n' | sed -E 's/.*HTTP_STATUS:([0-9]{3})$/\1/')

# Fail pipeline and print errors if API doesn't return an OK status.
if [ "${HTTP_STATUS}" -eq "200" ]; then
  echo "Successfully purged!"
  exit 0
else
  echo "Purge failed. API response was: "
  echo "${HTTP_BODY}"
  exit 1
fi
