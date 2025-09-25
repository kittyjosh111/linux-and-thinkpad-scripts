#for argos (https://github.com/p-e-w/argos)
thinkvantage
echo "---"
if [ "$ARGOS_MENU_OPEN" == "true" ]; then
  echo "$(thinkvantage -v) | font=monospace"
fi
