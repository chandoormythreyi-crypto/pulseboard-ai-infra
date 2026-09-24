# https://stackoverflow.com/questions/69247498/how-can-i-calculate-the-thumbprint-of-an-openid-connect-server

HOST=$(curl https://vstoken.actions.githubusercontent.com/.well-known/openid-configuration \
| jq -r '.jwks_uri | split("/")[2]')

THUMBPRINT=$(echo | openssl s_client -servername $HOST -showcerts -connect $HOST:443 2> /dev/null \
| sed -n -e '/BEGIN/h' -e '/BEGIN/,/END/H' -e '$x' -e '$p' | tail +2 \
| openssl x509 -fingerprint -noout \
| sed -e "s/.*=//" -e "s/://g" \
| tr "ABCDEF" "abcdef")

echo $THUMBPRINT
