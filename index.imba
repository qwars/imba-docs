const ImbaCompiler = require 'imba/src/compiler/compiler'

const SearchProperties = do|data|
	let properties = for item, idx in data:options:_tokens
		item:_type === 'PROP' and [ data:options:_tokens[ idx + 1 ]:_value, console.log data:options:_tokens.slice idx - 3, [ idx + 1 ] ]
	properties.filter do !!$1

const SearchMethods = do|data|
	# console.log data

const SearchEvents = do|data| [].concat( data:js.match( /on\$(.+?)\./g ) )
	.filter( do $1 )
	.map( do $1.match /['"]\w+['"]/g )
	.map( do  )

const SearchTags = do|data|
	let tags = data:js.match /@TAGS.+/i
	if tags then tags[0].split('|')
		.map( do $1.split(/\s-\s/).reverse[0].trim )
		.filter( do !!$1 )

const ReHerecomment = RegExp.new '\\@(?:tag|prop|method|event)s', 'i'


export class ImbaDocs
	prop tags default: Array.new
	prop properties default: Map.new
	prop events default: Map.new
	prop methods default: Map.new

	def compiled
		@compiled

	def compiled= v
		const normaliseHerecomment = do|code| code.map( do $1.split( ReHerecomment )[0] )
			.map do $1.split( /\r?\n/ ).map( do $1.replace /^\t\t/, '' ).filter(do $1)
		const normaliseValueHerecomment = do [
			$1[0].split('/')[0],
				type: $1[0].split('/')[1]
				properties: $1.slice(1).filter( do /[$]\d+/.test $1 )
				displayName: $1.slice(1).filter( do !/[$]\d+/.test $1 ).map(do $1.trim.replace(/^-\s*/, ''))[0] or ''
				displayDescription: $1.slice(1).filter( do !/[$]\d+/.test $1 ).map(do $1.trim.replace(/^-\s*/, ''))[1] or ''
			]
		const valueHerecomment = do|value, idx, list|
			if /^\w/.test value then normaliseValueHerecomment [ $1.split(':')[0].split('-')[0].trim ]
				.concat( $1.replace(/-/, '\t-').match(/\t-.+/) )
				.filter(do $1)
				.concat for seting in list.slice idx + 1
					break unless /^\t/.test seting
					seting

		for item, idx in v:options:_tokens
			if item:_type === 'HERECOMMENT' and item:_value.match ReHerecomment
				normaliseHerecomment( item:_value.split(/\@props\s*\:*/i).slice(1) )
					.flat.map( valueHerecomment ).filter(do $1)
					.map do properties.set $1[0], $1[1]
				normaliseHerecomment( item:_value.split(/\@events\s*\:*/i).slice(1) )
					.flat.map( valueHerecomment ).filter(do $1)
					.map do events.set $1[0], $1[1]
				normaliseHerecomment( item:_value.split(/\@methods\s*\:*/i).slice(1) )
					.flat.map( valueHerecomment ).filter(do $1)
					.map do methods.set $1[0], $1[1]
				properties.set '@TAGS', normaliseHerecomment( item:_value.split(/\@tags\s*\:*/i).slice(1) ).flat
					.map( do $1.trim.split '|' ).flat
					.map( do $1.replace( /^-/, '' ).trim )
					.filter( do $1 )
			elif item:_type === 'PROP' then console.log 'PROP', v:options:_tokens[ idx + 1 ]:_value, v:options:_tokens.slice idx - 2, 2
			elif item:_type === 'DEF' then console.log 'DEF', v:options:_tokens[ idx + 1 ]:_value, v:options:_tokens.slice idx - 2, idx

		@compiled = v

	def toString
		# console.log @compiled

	def toFunction
		console.log @compiled


	def initialize text
		compiled = ImbaCompiler.compile text if text
		self