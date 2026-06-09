# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.min.js", preload: true
pin "@popperjs/core", to: "popper.js", preload: true
pin "tone", to: "https://esm.sh/tone@15.1.22"
pin "@babel/runtime/helpers/classCallCheck", to: "@babel--runtime--helpers--classCallCheck.js" # @7.29.7
pin "@babel/runtime/helpers/createClass", to: "@babel--runtime--helpers--createClass.js" # @7.29.7
pin "@babel/runtime/helpers/slicedToArray", to: "@babel--runtime--helpers--slicedToArray.js" # @7.29.7
pin "automation-events" # @7.1.19
pin "standardized-audio-context" # @25.3.77
pin "tslib" # @2.8.1
