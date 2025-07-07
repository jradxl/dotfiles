#!/bin/bash

echo "Installing or upgrading the POETRY"

### curl -sSL https://install.python-poetry.org | python3 -

if [[ $(command -v lastversion)  ]]; then
	LATEST_VERSION=$(lastversion https://github.com/python-poetry/poetry)
else
	echo "Please ensure Pipx and Lastversion are installed"
	exit 1
fi

CURRENT_VERSION=$(poetry --version | awk '{print $3}')
CURRENT_VERSION=${CURRENT_VERSION::-1}
echo "CURRENT: $CURRENT_VERSION"
echo "LATEST: $LATEST_VERSION"

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
	echo "Already the current version."
	exit 0
fi

curl -sSL https://install.python-poetry.org | python3 

echo ""

poetry --version
echo "Done"

exit 0

