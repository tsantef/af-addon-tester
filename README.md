af-addon-tester
===============

<img src="http://appfog.com/images/logo.png" />

Allows developers to test add-ons compatible with App Fog

## Setup ##

1) Clone or Gem Install

Clone:

    $ git clone git@github.com:tsantef/af-addon-tester.git

Gem:

    $ gem install af-addon-tester


2) Create a manifest.json that points to a test addon

Example

    {
      "id":"myaddon",
      "api":{
        "plans":[
          {"id":"free"}
        ],
        "config_vars": {
          "MYADDON_URL":"http://some.url.com",
          "MYADDON_VAR1":"cats",
          "MYADDON_VAR2":"dogs"
        },
        "test":"http://localhost:4567/myaddon/resources",
        "password":"cavef6azebRewruvecuch",
        "sso_salt":"8ouy3ayLEyOA7HLAKO2Yo"
      }
    }


## Usage ##

If cloned:

    $ bin/af-addon-tester <path to manifest>

If Gem:

    $ af-addon-tester <path to manifest>


## Meta ##

Maintained by Tim Santeford.

Released under the MIT license.
