# frozen_string_literal: true

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'jquery', preload: true # @3.7.1
pin 'bootstrap', preload: true # @5.3.3
pin '@popperjs/core', to: '@popperjs--core.js', preload: true # @2.11.8
pin_all_from 'app/javascript/controllers', under: 'controllers'
