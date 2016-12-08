# Add composer global bin to $PATH

if [ "$COMPOSER_HOME" ]; then
  export PATH=$COMPOSER_HOME/vendor/bin:$PATH
else
  export PATH=~/.composer/vendor/bin:$PATH
fi
