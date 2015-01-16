# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	$('#show_info').click (event) ->
		$('#participation_teams_info').show()
		$('#participation_teams').hide()
		event.preventDefault()

	$('#show_teams').click (event) ->
		$('#participation_teams_info').hide()
		$('#participation_teams').show()
		event.preventDefault()

	if $('#show_info').length
		$('#participation_teams_info').hide()
				