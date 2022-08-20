
const searchTypes = "\\@((tag|param|method|event)s)"

const ReHereHerecomment = RegExp.new "^\\s*###"
const ReCommen = RegExp.new "^\\s*#(?!#)"
const ReCommenReplace = RegExp.new "(^\\s*#+\s*)|(#+\s*$)", 'g'
const ReFullDocCommen = RegExp.new "{searchTypes}\\b"
const ReFullDocCommenType = RegExp.new "(?<block>{searchTypes})(?<comment>[^@]*)", 'sgi'
const ReDocCommenType = RegExp.new "(?<block>{searchTypes})(?<comment>.*)", 'si'
const ReSpace = RegExp.new '^\\s+'

const ReParamTypeName = RegExp.new '\\s+(?<param>(\\@*[a-z][a-z-]+)|\\$\\d+)(\\/(?<type>[a-z][a-z-]+))*(\\s*-*\\s*(?<displayName>.+))*', 'i'

const ReNameSet = RegExp.new '^\\s*(?<set>(prop|def))\\s+(?<name>[a-z][a-z-]+)', 'i'

const herecommentReducer = do|current, item, idx|
	if current.at(-1) and current.at(-1) isa Array and  not current.at(-1).at(-1).match ReHereHerecomment then current.at(-1).push item
	elif current.at(-1) and current.at(-1) isa String and current.at(-1).match ReHereHerecomment then current[ current:length - 1 ] = [ current.at(-1) ].concat item
	else current.push item
	current

const herecommentNormalize = do|current, item, idx|
	if item isa Array then current.push item.join '\n'
	else current.push item
	current

const commentPropDevNormalize = do|current, item, idx|
	if item isa String and item.match ReFullDocCommen then current.push item
	else
		const propdev = item isa String and item.match ReNameSet
		unless propdev then current.push item
		else
			current.push [item].concat( for comment in current.slice(0, idx).reverse
				break if comment isa Array
				break if comment.match ReFullDocCommen
				continue current.pop unless comment.trim
				break if 0 > comment.search /^\s*#/
				current.pop
			).filter( do $1 isa String ? !!$1.trim : !!$1 ).reverse
	current

const createParamBlock = do|current, item, idx|
	if item and not current.at(-1) then current.push item
	elif item
		const sSpace = item.match( ReSpace )[0]:length
		const eSpace = (current.at(-1) isa Array ? current.at(-1)[0] : current.at(-1) ).match( ReSpace )[0]:length
		if sSpace <= eSpace then current.push item
		elif current.at(-1) isa Array then current[ current:length - 1 ].push item
		else current[ current:length - 1 ] = [ current.at(-1) ].concat item
	current

const createMapData = do $1.split(/\r?\n/).reduce( createParamBlock, Array.new ).map do
	unless $1 isa Array then $1
	else [ $1[0] ].concat $1.slice(1).reduce createParamBlock, Array.new

const setMapData = do|mapset, item = ''|
	const params = ( item isa Array ? item[0] : item ).match ReParamTypeName
	if params
		const dataset = Map.new [
			[ 'type', params:groups:type ]
			[ 'displayName', params:groups:displayName ]
		]
		if item isa Array
			const subparams = item.slice(1).filter do $1 isa Array
			if subparams:length then dataset.set 'params', subparams.reduce setMapData, Map.new
			item.slice(1).filter( do not( $1 isa Array ) ).map do
				if $2 then dataset.set 'displayDescription', $1.trim.replace /^-\s*/, ''
				elif dataset.get 'displayName' then dataset.set 'displayDescription', $1.trim.replace /^-\s*/, ''
				else  dataset.set 'displayName', $1.trim.replace /^-\s*/, ''
		mapset.set params:groups:param, dataset

const herecommentNormalizeMap = do
	const isSetName = $1[0].match ReNameSet
	const setings = unless $1[1] then $1[1]
	elif $1[1].match ReHereHerecomment then setMapData Map.new, createMapData( $1[1].replace ReCommenReplace, '' )[0]
	elif $1[1].match ReCommenReplace
		const comment = [ $1[1].replace( ReCommenReplace, '' ).trim ]
		if $1[2] and $1[2].match ReCommenReplace then comment.push $1[2].replace( ReCommenReplace, '' ).trim
		comment.filter( do !$1.match /^@/ ).reverse.reduce
			do
				const mp = $1.get('@prop') or $1.get('@event') or $1.get('@method') or $1.get('@function')
				if $3 then mp.set 'displayDescription', $2
				elif mp.get 'displayName' then mp.set 'displayDescription', $2
				else mp.set 'displayName', $2
				$1
			setMapData( Map.new, createMapData ' '.concat comment.filter( do $1.match /^@/ )[0] or '\t' ) or Map.new [ [
				( isSetName:groups:set === 'prop' ? '@prop' : '@function'),
				Map.new
			] ]
	setings.set 'mapkey', isSetName:groups:name if setings

export class ImbaDocs
	prop properties default: Map.new
	prop functions default: Map.new
	prop methods default: Map.new
	prop events default: Map.new

	def source= v = []
		for item, idx in @source = v
			if item isa String and item.match ReFullDocCommen then item.match( ReFullDocCommenType ).map do|comment|
				const reMatch = comment.match ReDocCommenType
				if reMatch[2].match /tags/i then properties.set '@TAGS', reMatch:groups:comment.split('|').map do $1.trim
				elif reMatch[2].match /params/i then createMapData( reMatch:groups:comment ).reduce setMapData, properties
				elif reMatch[2].match /methods/i then createMapData( reMatch:groups:comment ).reduce setMapData, methods
				elif reMatch[2].match /events/i then createMapData( reMatch:groups:comment ).reduce setMapData, events
			elif item isa Array
				const settings = herecommentNormalizeMap item.slice.reverse
				if settings and settings.get '@prop' then properties.set
					settings.get 'mapkey'
					settings.get '@prop'
				elif settings and settings.get '@method' then methods.set
					settings.get 'mapkey'
					settings.get '@method'
				elif settings and settings.get '@event' then events.set
					settings.get 'mapkey'
					settings.get '@event'
				elif settings and settings.get '@function' then functions.set
					settings.get 'mapkey'
					settings.get '@function'

	def toString
		const is-used = {}

		const indetSet = do|indent| "{ indent +  '\t' }" # TODO: test for indent as space
		const typeString = do|type| !type ? '' : "/{ type }"
		const nameString = do|description|  !description ? '' : "- { description }"
		const paramsString = do|mapset, indent|
			[
				"{ indent }{ mapset[0] }{ typeString mapset[1].get 'type' }"
				mapset[1].get( 'displayName' ) and "{ indetSet indent  }{ nameString mapset[1].get 'displayName' }"
				mapset[1].get( 'displayDescription') and "{ indetSet indent  }{ nameString mapset[1].get 'displayDescription' }"
			].concat( for item in mapset[1].get('params') and Array.from mapset[1].get('params').entries
				paramsString( item, indetSet indent ).flat ).flat

		const getMapTYpe = do
			if methods.get $1 then [ '@method', methods.get $1 ]
			elif events.get $1 then [ '@event', events.get $1 ]
			elif functions.get $1 then [ '@function', functions.get $1 ]

		const templatePropDef = do|items|
			const propdev = items.at(-1).match ReNameSet
			const indents = items.at(-1).match ReSpace

			const mapType = propdev:groups:set === 'prop' ? [ '@prop', properties.get( propdev:groups:name ) ] : getMapTYpe propdev:groups:name
			if mapType and mapType[1]
				is-used[ mapType[0] ] = [] unless is-used[ mapType[0] ]
				is-used[ mapType[0] ].push propdev:groups:name
				let content = [
					""
					items[1].match( /^\s*###/ ) and items[0].match( /^\s*#/ ) and items[0]
					""
				];
				unless content[1] then content = [""]
				items = [
					content
					"{ indents }###"
					].concat( paramsString( mapType, indetSet indents ).flat )
					.concat( "{ indents }###" )
					.concat( items.at(-1) ).flat
			items

		const replacePropDefComment = do|current, item|
			unless item isa Array then current.push item
			else current.push templatePropDef item
			current

		const reBuildHerecomment = do|current, item|
			if item isa Array or not item.match ReFullDocCommenType then current.push item
			elif not is-used:fullherecomment
				const indents = item.match ReSpace
				const content = [
					properties.get( '@TAGS' ) and "{ indetSet indents }@tags { properties.get( '@TAGS' ).join '|' }"
				]
				const params = Array.from( properties.entries, do if $1[0] !== '@TAGS' and not ( is-used['@prop'] and is-used['@prop'].includes $1[0] ) then paramsString $1, indetSet indetSet indents ).flat.filter do !!$1
				const events = Array.from( events.entries, do unless is-used['@event'] and is-used['@event'].includes $1[0] then paramsString $1, indetSet indetSet indents  ).flat.filter do !!$1
				const methods = Array.from( methods.entries, do unless is-used['@method'] and is-used['@method'].includes $1[0] then paramsString $1, indetSet indetSet indents  ).flat.filter do !!$1
				content.push ["{ indetSet indents }@events"].concat events if events:length
				content.push ["{ indetSet indents }@methods"].concat methods if methods:length
				content.push ["{ indetSet indents }@params"].concat params if params:length
				is-used:fullherecomment = !content.filter( do !!$1 ):length or current.push [
					"{ indents }###"
					content.flat.join '\n'
					"{ indents }###"
				].flat.join '\n'
			current

		console.log @source.reduce( replacePropDefComment, Array.new ).reduce( reBuildHerecomment, Array.new ).flat.join '\n'

	def initialize text = ''
		source = text.split( /\r?\n/ )
			.reduce( herecommentReducer, Array.new )
			.reduce( herecommentNormalize, Array.new )
			.reduce( commentPropDevNormalize, Array.new )
		self