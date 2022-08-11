const ImbaCompiler = require 'imba/src/compiler/compiler'

const searchMeta = '(?<meta>^\\@(prop\|event\|method))'
const searchName = '(?<displayName>[\\s]+-.+)'
const searchDecription = '(?<displayDescription>[\\s]+-.+(\\s+-+)*)'
const searchParam = '(?<param>\\n\\s+([a-zA-Z][a-zA-Z0-9]+|\\$\\d+))'
const searchType = '(?<type>\\/\\w+)'
const paramsSearch = "{ searchParam }{searchType}*({ searchName }{ searchDecription }*)*"

const ReHerecomment = RegExp.new '\\@(?:tag|prop|method|event)s', 'i'
const ReSearchMeta = RegExp.new searchMeta
const ReSearchName = RegExp.new searchName, 'g'
const ReParamsSearch = RegExp.new paramsSearch
const ReParamsSearchGlobal = RegExp.new paramsSearch, 'g'
const ReSearchType = RegExp.new "{searchMeta}{searchType}"

const mapItemSet = do for own k, v of $1
	[ k, v and v.trimEnd.replace /^[\s-\/]+/, '' ]


const getTypeComment = do
	if $1 and $1:groups:type then $1:groups:type.trim.toUpperCase.replace /^\/\s*/, ''
	else undefined

const mapData = do
	let comments = [].concat( for item in $2.reverse
		break unless ['INDENT','TERMINATOR', 'HERECOMMENT'].includes item:_type
		if item:_meta then item:_meta:post.trim
		else item:_value.trim
	)
	.map( do $1.replace /^\s*\/+\s*/, '' )
	.filter( do !!$1 )
	.sort do|a,b|
		if a.match ReSearchMeta then -1
		else 1


	return unless comments:length
	unless comments[0].match ReSearchMeta then Map.new [['meta', $1:_type ], [ token: $1 ]].concat comments
		.map( do  $1.split /\/+/ ).flat
		.map( do [ "display{ $2 ? 'Description' : 'Name' }", $1.replace( /^\s*\/+/, '' ).trim ])
	else
		let MaxIndent = Math:max.apply
			null
			[0].concat comments[0].match( ReSearchName )
				.map( do $1.split('-')[0]:length )

		let MinIndent = Math:min.apply
			null
			[MaxIndent].concat comments[0].match( ReSearchName )
				.map( do $1.split('-')[0]:length )

		Map.new(
			comments[0].replace(/\s*\/\//, '\n - ').match( ReSearchName  )
				.filter( do MaxIndent === MinIndent or $1.split('-')[0]:length <= MaxIndent  )
				.concat( comments[1] ).filter( do !!$1 )
				.map( do
					comments[0] = comments[0].replace $1, ''
					["display{ $2 ? 'Description' : 'Name' }", $1 and $1.trimEnd.replace(/^\s*-\s*/, '')]
				)
				.concat [[
						'params',
						for item in comments[0].match ReParamsSearchGlobal
							let param = Map.new( mapItemSet item.match( ReParamsSearch ):groups )
							[ param.get('param'), param  ]
					]]
				.concat [[ 'token', $1 ]]
				.concat [[
						'meta',
						comments[0].match( ReSearchMeta ):groups:meta.toUpperCase.replace /\@/, ''
					]]
				.concat [[
						'type',
						getTypeComment comments[0].match ReSearchType
					]]

		)

export class ImbaDocs
	prop tags default: Array.new
	prop properties default: Map.new
	prop events default: Map.new
	prop methods default: Map.new
	prop functions default: Map.new

	def compiled
		@compiled

	def compiled= v
		functions = Map.new
		properties = Map.new
		events = Map.new
		methods = Map.new

		const normaliseHerecomment = do|code|
			code.map( do $1.split( ReHerecomment )[0] )
				.map do $1.split( /\r?\n/ ).map( do $1.replace /^\t\t/, '' ).filter(do $1)

		const normaliseValueHerecomment = do [
			$1[0].split('/')[0], Map.new [
				['type', $1[0].split('/')[1]]
				[ 'params', $1.slice(1).filter( do /[$]\d+/.test $1 ).map( do $1.trim ) ] # TODO: Обработчик входящих данных в функцию ( GET - SET )
				[ 'displayName', $1.slice(1).filter( do !/[$]\d+/.test $1 ).map(do $1.trim.replace(/^-\s*/, ""))[0] ]
				[ 'displayDescription', $1.slice(1).filter( do !/[$]\d+/.test $1 ).map(do $1.trim.replace(/^-\s*/, ""))[1] ]
			]]

		const valueHerecomment = do|value, idx, list|
			if /^\w/.test value then normaliseValueHerecomment [ $1.split(/[- :]+/)[0].trim ]
				.concat( $1.replace(/^[\w-]+(\/\w+)*/, '') )
				.concat( $1.replace(/-/, '\t-').match(/\t-.+/) )
				.filter(do $1)
				.concat for seting in list.slice idx + 1
					break unless /^\t/.test seting
					seting

		const setMapData = do
			unless $2 then return
			elif 'DEF' === $2.get 'meta' then functions.set $1, $2
			elif 'METHOD' === $2.get 'meta' then methods.set $1, $2
			elif 'EVENT' === $2.get 'meta' then events.set $1, $2
			elif 'PROP' === $2.get 'meta' then properties.set $1, $2


		try
			if  v:js.includes 'tag.prototype' or 'function' == v:js.substr 0, 9
				for item, idx in v:options:_tokens
					if item:_type === 'HERECOMMENT' and item:_value.match ReHerecomment
						normaliseHerecomment( item:_value.split(/\@props[\s:-]*/i).slice(1) )
							.flat.map( valueHerecomment ).filter(do $1)
							.map do properties.set $1[0], $1[1].set
								[ 'token', item ]

						normaliseHerecomment( item:_value.split(/\@events[\s:-]*/i).slice(1) )
							.flat.map( valueHerecomment ).filter(do $1)
							.map do events.set $1[0], $1[1].set
								[ 'token', item ]

						normaliseHerecomment( item:_value.split(/\@methods[\s:-]*/i).slice(1) )
							.flat.map( valueHerecomment ).filter(do $1)
							.map do methods.set $1[0], $1[1].set
								[ 'token', item ]

						properties.set '@TAGS', Set.new Array.from(
							item:_value.matchAll( /\@tags(.+)/gi ),
							do $1[0].replace(/\@tags[\s:-]+/, '').split('|') ).flat.map( do $1.trim ).filter( do !!$1 )

					elif item:_type === 'PROP' then setMapData
						v:options:_tokens[ idx + 1 ]:_value
						mapData
							item
							v:options:_tokens.slice 0, idx

					elif item:_type === 'DEF' then setMapData
						v:options:_tokens[ idx + 1 ]:_value,
						mapData
							item
							v:options:_tokens.slice 0, idx

			@compiled = v
		catch e
			console.dir e

	def toImba
		console.log  methods

	def toFunction
		console.log @compiled


	def initialize text
		compiled = ImbaCompiler.compile text if text

		self