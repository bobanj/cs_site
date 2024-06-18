# frozen_string_literal: true

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'jquery', preload: true # 3.7.1
pin 'bootstrap', to: 'https://ga.jspm.io/npm:bootstrap@5.3.3/dist/js/bootstrap.esm.js', preload: true
pin '@popperjs/core', to: 'https://ga.jspm.io/npm:@popperjs/core@2.11.8/lib/index.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
