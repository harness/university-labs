echo -e "\n\n======= MY VARIABLES ========"
echo -e "USER: \t\t$MY_HARNESS_USER"
echo -e "PASSWORD: \t$MY_HARNESS_PASSWORD"
echo -e "LINK: \t\t$MY_HARNESS_LINK"
if [[ -z "$MY_HARNESS_USER_PAT" ]]; then echo -e "PAT: \t\tNot set"; else echo -e "PAT:\t\tIs set"; fi