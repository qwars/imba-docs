 

# DescriptionEvent
def onEvent e
	console.log e

# DescriptioMethod
def isMethod param
	console.log param

# Event Two name
# Descriptio Event Two
def onEventTwo e
	console.log e

# Two Method name
# Descriptio Method Type Two
def isMethodTypeTwo param
	console.log param

# @event - Event name
def onEventType e
	console.log e

# @method - Method name
def isMethodType param
	console.log param

# @event - Event name
# Descriptio Event Type Two
def onEventTypeTwo e
	console.log e

# @method - Method name
# Descriptio Method Type Two
def isMethodTypeTwo param
	console.log param


###
	@event - Event Block name
###
def onEventTypeBlock e
	console.log e

###
	@method - Method Block name
###
def isMethodTypeBlock param
	console.log param

###
	@event - Event Block name
###
# Description Event block Two
def onEventTypeBlockTwo e
	console.log e

###
	@method - Method Block name
###
# Descriptiom Method block Two
def isMethodTypeBlockTwo param
	console.log param

###
	@event
		- Event params name
		- Event paras description
###
def onEventTypeBlocParams e
	console.log e

###
	@method
		- Method params name
		- Method params description
###
def isMethodTypeBlockParams param
	console.log param

###
	@method
		- Method params name
		- Method params description
		param
###
def isMethodTypeProperty param
	console.log param

###
	@method
		- Method params name
		- Method params description
		param/string
			- Display Name
			- Display Description
###
def isMethodTypePropertyFull param
	console.log param

###
	@method
		- Method params name
		- Method params description
		param/string
			- Display Name
			- Display Description
		state/number
			- State Display Name
			- State Display Description
###
def isMethodTypePropertyFull param, state
	console.log param

###
	@method
		- Method params name
		- Method params description
		$1/string
			- Display Name
			- Display Description
		$2/number
			- State Display Name
			- State Display Description
###
def isMethodTypePropertyFullNoName param, state
	console.log param

###
	@method
		$1/string
			- Display Name
			- Display Description
		$2/number
			- State Display Name
			- State Display Description
		- Method params name isMethodTypePropertyFullEndName
		- Method params description isMethodTypePropertyFullEndName
###
def isMethodTypePropertyFullEndName param, state
	console.log param


###
	@event
		- Event name
		- Event description
###
def onEventPropertyFull
	console.log data


