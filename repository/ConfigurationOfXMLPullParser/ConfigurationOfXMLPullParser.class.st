"
(ConfigurationOfXMLPullParser project version: #stable) load
 
"
Class {
	#name : #ConfigurationOfXMLPullParser,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfXMLPullParser
}

{ #category : #'development support' }
ConfigurationOfXMLPullParser class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfXMLPullParser class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #catalog }
ConfigurationOfXMLPullParser class >> catalogChangeLog [
		
 ^ '
-14/08/2013 - First public release.
[[[
(ConfigurationOfXMLPullParser project version: #''stable'') load
]]]
'
	
	
]

{ #category : #catalog }
ConfigurationOfXMLPullParser class >> catalogDescription [

^ 
'XMLPullParser is a robust parser for XML.'
]

{ #category : #catalog }
ConfigurationOfXMLPullParser class >> catalogKeyClassesAndExample [

	^ 'It is composed of some keys classes: 
		
- ==XMLPullParser== is the main entry point.
		
- ==XMLPullParserTest== is the main entry point.

The best way to get started is to get a  of html elements using ==XMLPullParser class>>parse: == as follows:

[[[ 
	| parser |
	parser := XMLPullParser parse: ''<document><![CDATA[This is a test ]]></document>''.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: ''document'').
	self assert: parser next isText.
	self assert: parser text = ''This is a test ''.
	self assert: (parser isEndTag: ''document'').
	self assert: parser next isEndDocument
]]]
	
Tests of the ==XMLPullParserTest== class are the place to start to learn the API.'
]

{ #category : #catalog }
ConfigurationOfXMLPullParser class >> catalogKeywords [
	^ #(XML web parser)
	
]

{ #category : #private }
ConfigurationOfXMLPullParser class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfXMLPullParser class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfXMLPullParser class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfXMLPullParser class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfXMLPullParser class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfXMLPullParser class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfXMLPullParser class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfXMLPullParser class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfXMLPullParser >> baseline10: spec [
	<version: '1.0-baseline'>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'http://www.smalltalkhub.com/mc/hernan/XMLPullParser/main'.
		spec package: 'XMLPullParser'.
		spec group: 'default' with: #('XMLPullParser' ). ].

]

{ #category : #baselines }
ConfigurationOfXMLPullParser >> baseline14: spec [
	<version: '1.4-baseline'>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'http://www.smalltalkhub.com/mc/hernan/XMLPullParser/main'.
		spec package: 'XMLPullParser'.
		spec group: 'default' with: #('XMLPullParser' ). ].

]

{ #category : #accessing }
ConfigurationOfXMLPullParser >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #'symbolic versions' }
ConfigurationOfXMLPullParser >> development: spec [
	<symbolicVersion: #'development'>

	spec for: #'common' version: '1.4-baseline'.

]

{ #category : #accessing }
ConfigurationOfXMLPullParser >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		project := MetacelloMCProject new projectAttributes: self customProjectAttributes. 
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfXMLPullParser >> stable: spec [
	<symbolicVersion: #'stable'>

	spec for: #'common' version: '1.4'.

]

{ #category : #versions }
ConfigurationOfXMLPullParser >> version10: spec [
	<version: '1.0' imports: #('1.0-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'release'.
		spec description: ''.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '8/14/2013 08:29'.
		spec package: 'XMLPullParser' with: 'XMLPullParser-HernanMoralesDurand.13'. ].

]

{ #category : #versions }
ConfigurationOfXMLPullParser >> version11: spec [
	<version: '1.1' imports: #('1.0-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'release'.
		spec description: 'Adding class comments and some little cleans'.
		spec author: 'StephaneDucasse'.
		spec timestamp: '27/10/2013 08:29'.
		spec package: 'XMLPullParser' with: 'XMLPullParser-StephaneDucasse.15'. ].

]

{ #category : #versions }
ConfigurationOfXMLPullParser >> version12: spec [
	<version: '1.2' imports: #('1.0-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'release'.
		spec description: '#parseError: fix by Johan Brichau'.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '26/04/2014 08:29'.
		spec package: 'XMLPullParser' with: 'XMLPullParser-JohanBrichau.19'. ].

]

{ #category : #versions }
ConfigurationOfXMLPullParser >> version13: spec [
	<version: '1.3' imports: #('1.0-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'release'.
		spec description: 'All green tests now for Pharo 3.0'.
		spec author: 'SergeStinckwich'.
		spec timestamp: '08/06/2014 22:59'.
		spec package: 'XMLPullParser' with: 'XMLPullParser-SergeStinckwich.20'. ].

]

{ #category : #versions }
ConfigurationOfXMLPullParser >> version14: spec [
	<version: '1.4' imports: #('1.4-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'stable'.
		spec description: 'version 1.4'.
		spec author: 'HernanMoralesDurand'.
		spec timestamp: '7/29/2014 12:35'.
		spec package: 'XMLPullParser' with: 'XMLPullParser-HernanMoralesDurand.22'. ].

]
