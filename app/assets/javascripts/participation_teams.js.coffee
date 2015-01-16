# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
	$('#show_info').click (event) ->
		$('#show_info').hide()
		$('#participation_teams').hide()
		$('#show_teams').show()
		$('#participation_teams_info').show()
		event.preventDefault()

	$('#show_teams').click (event) ->
		$('#show_teams').hide()
		$('#participation_teams_info').hide()
		$('#show_info').show()
		$('#participation_teams').show()
		event.preventDefault()

	if $('#show_info').length
		$('#show_teams').hide()
		$('#participation_teams_info').hide()
				