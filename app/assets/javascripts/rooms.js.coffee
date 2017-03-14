# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#不知道为什么以下js里的选择器失效
$(document).on "turbolinks:load", ->
  $('#flash').click (
    ()->
      $(this).hide()
      console.log("xx")
  )

  $('#instructions').click (
    () ->
      $('#instructions_content').dimmer('toggle')
  )

  $('#bug_report').click (
    () ->
      $('.basic.modal').modal('show')
  )

  $('.project').click (
    () ->
      location.href="https://github.com/1625081/times"
  )
