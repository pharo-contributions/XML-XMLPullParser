"
XMLPushParser is a stream-based XMLParser originally developed by Antony Blakey and released under MIT license. 


We could use cull: instead of numArgs = 1
"
Class {
	#name : #XMLPullParser,
	#superclass : #Object,
	#instVars : [
		'stream',
		'current',
		'nestedStreams',
		'entities',
		'externalEntities',
		'parameterEntities',
		'parsingMarkup',
		'markedPosition',
		'peekChar',
		'nameBuffer',
		'attributeBuffer',
		'eventQueue'
	],
	#classVars : [
		'CharEscapes',
		'DigitTable',
		'LiteralChars',
		'NameDelimiters',
		'SeparatorTable'
	],
	#category : 'XMLPullParser'
}

{ #category : #'instance creation' }
XMLPullParser class >> initialize [
	"XMLPullParser initialize"

	| nameDelimiters |

	CharEscapes := #( $& $" $' $> $< ) asSet.

	SeparatorTable := Array new: 256.
	SeparatorTable atAllPut: true.
	#(9 10 12 13 32) do: [:each | SeparatorTable at: each+1 put: false].

	LiteralChars := Array new: 256.
	LiteralChars atAllPut: false.
	':-:=.' do: [:each | LiteralChars at: each asciiValue put: true].
	1 to: 256 do: [:i | ((i-1) asCharacter isDigit or: [(i-1) asCharacter isLetter])
		ifTrue: [LiteralChars at: i put: true]].

	nameDelimiters := #(9 10 12 13 32 61 "$= asInteger 61" 62 "$> asInteger" 47 "$/ asInteger").
	NameDelimiters := Array new: 256.
	NameDelimiters atAllPut: false.
	nameDelimiters do: [:each | NameDelimiters at: each put: true].

	DigitTable := Array new: 256.
	DigitTable atAllPut: -1.
	0 to: 15
	    do: [:each | DigitTable at: (Character digitValue: each) asciiValue put: each]
]

{ #category : #accessing }
XMLPullParser class >> isCharEscape: aChar [
	^CharEscapes includes: aChar
]

{ #category : #'instance creation' }
XMLPullParser class >> parse: source [ 
	^ self new parse: source
]

{ #category : #'delegating accessors' }
XMLPullParser >> at: attName [ 
	^self current at: attName
]

{ #category : #'delegating accessors' }
XMLPullParser >> at: attName ifFound: aFoundBlock ifNone: aBlock [
	^self current at: attName ifFound: aFoundBlock ifNone: aBlock
]

{ #category : #'delegating accessors' }
XMLPullParser >> at: attName ifNone: aBlock [
	^self current at: attName ifNone: aBlock
]

{ #category : #streaming }
XMLPullParser >> atEnd [
	nestedStreams == nil ifTrue: [^ peekChar == nil and: [stream atEnd]].
	^ stream atEnd 
		ifTrue: 
			[self popNestingLevel.
			self atEnd]
		ifFalse: [false]
]

{ #category : #'tag-based api' }
XMLPullParser >> collect: tagName peek: aBlock [ 
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [ result add: (self matchAnyPeek: aBlock) ].
	^result
]

{ #category : #'tag-based api' }
XMLPullParser >> collect: tagName take: aBlock [ 
	| result |
	result := OrderedCollection new.
	self while: tagName peek: [ result add: (self matchAnyTake: aBlock) ].
	^result
]

{ #category : #'tag-based api' }
XMLPullParser >> collectAnyPeek: aBlock [ 
	| result |
	result := OrderedCollection new.
	self whileAnyPeek: [ result add: (self matchAnyPeek: aBlock) ].
	^result
]

{ #category : #'tag-based api' }
XMLPullParser >> collectAnyTake: aBlock [ 
	| result |
	result := OrderedCollection new.
	self whileAnyTake: [ result add: (self matchAnyPeek: aBlock) ].
	^result
]

{ #category : #'consuming events' }
XMLPullParser >> consumeEndTag [
	self mustBeEndTag.
	self next.
]

{ #category : #'consuming events' }
XMLPullParser >> consumeEndTag: tagName [
	self mustBeEndTag: tagName.
	self next.
]

{ #category : #'consuming events' }
XMLPullParser >> consumeStartDocument [
	self mustBeStartDocument.
	self next.
]

{ #category : #'consuming events' }
XMLPullParser >> consumeStartTag [
	self mustBeStartTag.
	self next.
]

{ #category : #'consuming events' }
XMLPullParser >> consumeStartTag: tagName [
	self mustBeStartTag: tagName.
	self next.
]

{ #category : #'consuming events' }
XMLPullParser >> consumeText [
	| text |
	self isText 
		ifTrue: 
			[self mustBeText.
			text := self current text.
			self next.
			^text]
		ifFalse: [^'']
]

{ #category : #'core api' }
XMLPullParser >> current [
	^ current
]

{ #category : #entities }
XMLPullParser >> entities [
	entities ifNil: [entities := self initEntities].
	^ entities
]

{ #category : #entities }
XMLPullParser >> entity: refName [ 
	^ self entities at: refName
		ifAbsentPut: [XPPStructureException raiseSignal: 'XML undefined entity ' , refName printString]
]

{ #category : #private }
XMLPullParser >> errorExpected: expectedString [
	XPPStructureException raiseSignal: 'Expected ', expectedString
]

{ #category : #private }
XMLPullParser >> fastStreamStringContents: writeStream [
	^writeStream contents
]

{ #category : #'tag-based api' }
XMLPullParser >> if: tagName peek: aBlock [ 
	(self is: tagName) ifTrue: [self matchAnyPeek: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> if: tagName peek: aBlock else: elseBlock [
	^(self is: tagName) ifTrue: [self matchAnyPeek: aBlock] ifFalse: [ elseBlock value ].
]

{ #category : #'tag-based api' }
XMLPullParser >> if: tagName take: aBlock [ 
	(self is: tagName) ifTrue: [self matchAnyTake: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> if: tagName take: aBlock else: elseBlock [
	^(self is: tagName) ifTrue: [self matchAnyTake: aBlock] ifFalse: [ elseBlock value ].
]

{ #category : #'tag-based api' }
XMLPullParser >> ifAnyPeek: aBlock [ 
	self isStartTag ifTrue: [self matchAnyPeek: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> ifAnyPeek: aBlock else: elseBlock [
	^self isStartTag ifTrue: [self matchAnyPeek: aBlock] ifFalse: [ elseBlock value ].
]

{ #category : #'tag-based api' }
XMLPullParser >> ifAnyTake: aBlock [ 
	self isStartTag ifTrue: [self matchAnyTake: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> ifAnyTake: aBlock else: elseBlock [
	^self isStartTag ifTrue: [self matchAnyTake: aBlock] ifFalse: [ elseBlock value ].
]

{ #category : #entities }
XMLPullParser >> initEntities [
	| ents |
	ents := Dictionary new.
	ents
		at: 'amp' put: $&;
		at: 'quot' put: $";
		at: 'apos' put: $';
		at: 'gt' put: $>;
		at: 'lt' put: $<.
	^ ents
]

{ #category : #'initialize-release' }
XMLPullParser >> initialize [
	super initialize.
	parsingMarkup := false.
	attributeBuffer := WriteStream on: (String new: 128).
	nameBuffer := WriteStream on: (String new: 128).
	eventQueue := OrderedCollection new
]

{ #category : #'testing event types' }
XMLPullParser >> is: tagName [
	^self isStartTag: tagName
]

{ #category : #'testing event types' }
XMLPullParser >> isEndDocument [
	^self current isEndDocument
]

{ #category : #'testing event types' }
XMLPullParser >> isEndTag [
	^self current isEndTag
]

{ #category : #'testing event types' }
XMLPullParser >> isEndTag: aStringOrNodeTag [
	^self current isEndTag: aStringOrNodeTag
]

{ #category : #'testing event types' }
XMLPullParser >> isStartDocument [
	^self current isStartDocument
]

{ #category : #'testing event types' }
XMLPullParser >> isStartTag [
	^self current isStartTag
]

{ #category : #'testing event types' }
XMLPullParser >> isStartTag: aStringOrNodeTag [
	^self current isStartTag: aStringOrNodeTag
]

{ #category : #'testing event types' }
XMLPullParser >> isText [
	^ self current isText
]

{ #category : #'tag-based api' }
XMLPullParser >> match: tagName peek: aBlock [ 
	"Throws an exception if the current event isn’t a start tag matching the given tag name. If it succeeds, then aBlock is evaluated without consuming the start tag event. The block can take zero or one argument. If it takes one argument then the cur
rent event is passed to the block."

	self mustBeStartTag: tagName.
	^self matchAnyPeek: aBlock
]

{ #category : #'tag-based api' }
XMLPullParser >> match: tagName take: aBlock [ 
	"Throws an exception if the current event isn’t a start tag matching the given tag name. If it succeeds, then aBlock is evaluated after consuming the start tag event. The block can take zero or one argument. If it takes one argument then the start tag event that was consumed is passed to the block, which can be useful for processing the attributes. After the block executes, the parser must be at an end tag matching the start tag. This end tag is then consumed."

	self mustBeStartTag: tagName.
	^self matchAnyTake: aBlock
]

{ #category : #'tag-based api' }
XMLPullParser >> matchAnyPeek: aBlock [ 
	"Throws an exception if the current event isn’t a start tag. If it succeeds, then then aBlock is evaluated without consuming the start tag event. The block can take zero or one argument. If it takes one argument then the current event is passed to the block."
	self mustBeStartTag.
	^aBlock numArgs = 1 
		ifTrue: [aBlock value: self current]
		ifFalse: [aBlock value]
]

{ #category : #'tag-based api' }
XMLPullParser >> matchAnyTake: aBlock [ 
	"Throws an exception if the current event isn’t a start tag. If it succeeds, then aBlock is evaluated after consuming the start tag event. The block can take zero or one argument. If it takes one argument then the start tag event that was consumed is passed to the block, which can be useful for processing the attributes. After the block executes the parser must be at an end tag matching the start tag. This end tag is then consumed."

	| result |
	result := aBlock numArgs = 1 
		ifTrue: 
			[ | tag |
			tag := self current.
			self consumeStartTag.
			aBlock value: tag ]
		ifFalse: 
			[ self consumeStartTag.
			aBlock value ].
	self consumeEndTag.
	^ result
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeEndDocument [
	self isEndDocument 
		ifFalse: [XPPStructureException raiseSignal: 'Expected end of document']
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeEndTag [
	self isEndTag 
		ifFalse: [XPPStructureException raiseSignal: 'Expected end tag']
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeEndTag: tagName [
	(self isEndTag: tagName)
		ifFalse: [XPPStructureException raiseSignal: 'Expected end tag: ', tagName]
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeStartDocument [
	self isStartDocument 
		ifFalse: [XPPStructureException raiseSignal: 'Expected start of document']
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeStartTag [
	self isStartTag
		ifFalse: [XPPStructureException raiseSignal: 'Expected start tag']
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeStartTag: tagName [
	(self isStartTag: tagName)
		ifFalse: [XPPStructureException raiseSignal: 'Expected start tag: ', tagName]
]

{ #category : #'asserting event types' }
XMLPullParser >> mustBeText [
	self isText
		ifFalse: [XPPStructureException raiseSignal: 'Expected text']
]

{ #category : #'core api' }
XMLPullParser >> next [
	eventQueue isEmpty ifFalse: [^ current := eventQueue removeFirst].
	self nextWhitespace.
	self atEnd ifTrue: [^ current := XPPEndDocument new].
	self peek = $< ifTrue: [self nextNode] ifFalse: [self nextPCData].
	^ current := eventQueue isEmpty 
				ifTrue: [self next]
				ifFalse: [eventQueue removeFirst]
]

{ #category : #streaming }
XMLPullParser >> nextAttributeInto: attributes namespaces: namespaces [ 
	| attrName attrValue |
	attrName := self nextName.
	self skipSeparators.
	self nextChar == $= ifFalse: [self errorExpected: '='].
	self skipSeparators.
	attrValue := self nextAttributeValue.
	(self usesNamespaces and: [attrName beginsWith: 'xmlns']) 
		ifTrue: 
			[attrName size > 6 
				ifTrue: 
					[namespaces at: (attrName copyFrom: 7 to: attrName size) put: attrValue]
				ifFalse: [namespaces at: attrName put: attrValue]]
		ifFalse: [attributes at: attrName put: attrValue]
]

{ #category : #streaming }
XMLPullParser >> nextAttributeValue [
	| delimiterChar attributeValueStream nextChar nextPeek referenceString entityValue |
	delimiterChar := self nextChar.
	(delimiterChar == $" or: [delimiterChar == $']) 
		ifFalse: [self errorExpected: 'Attribute value delimiter expected.'].
	attributeValueStream := attributeBuffer reset.
	
	[nextPeek := nextChar := self nextChar.
	nextChar ifNil: [self errorExpected: 'Character expected.'].
	nextChar == $& 
		ifTrue: 
			[self peek == $# 
				ifTrue: 
					[nextPeek := nil.
					nextChar := self nextCharReference]
				ifFalse: 
					[referenceString := self nextLiteral.
					self nextChar == $; ifFalse: [self errorExpected: ';'].
					entityValue := self entity: referenceString.
					(self class isCharEscape: entityValue) 
						ifTrue: 
							[nextPeek := nil.
							nextChar := entityValue]
						ifFalse: 
							[entityValue := entityValue asString.
							entityValue isEmpty 
								ifTrue: [nextPeek := nextChar := nil]
								ifFalse: 
									[self pushStream: (ReadStream on: entityValue asString).
									nextPeek := nextChar := self nextChar]]]].
	nextPeek == delimiterChar] 
			whileFalse: [nextChar ifNotNil: [attributeValueStream nextPut: nextChar]].
	^ self fastStreamStringContents: attributeValueStream
]

{ #category : #tokenizing }
XMLPullParser >> nextCDataContent [
	"Skip $[ "
	| cdata |
	self nextChar.
	cdata := self nextUpToAll: ']]>'.
	eventQueue addLast: (XPPText new text: cdata)
]

{ #category : #tokenizing }
XMLPullParser >> nextCDataOrConditional [

	| nextChar conditionalKeyword |
	"Skip ["
	self nextChar.
	self skipSeparators.
	nextChar := self peek.
	nextChar == $%
		ifTrue: [
			self checkAndExpandReference: (self parsingMarkup ifTrue: [#dtd] ifFalse: [#content]).
			conditionalKeyword := self nextLiteral.
			self skipSeparators.
			^self nextChar == $[
				ifTrue: [
						self skipSeparators.
						self nextIncludeSection: (self conditionalInclude: conditionalKeyword)]
				ifFalse: [self errorExpected: '[' ]].

	nextChar == $C
		ifTrue: [
			^self nextLiteral = 'CDATA'
				ifTrue: [self peek == $[
							ifTrue: [self nextCDataContent]
							ifFalse: [self errorExpected: '[' ]]
				ifFalse: [self errorExpected: 'CData']].
	self errorExpected: 'CData or declaration'

]

{ #category : #streaming }
XMLPullParser >> nextChar [
	"Return the next character from the current input stream. If the current stream is at end pop to next nesting level if there is one.
	Due to the potential nesting of original document, included documents and replacment texts the streams are held in a stack representing the nested streams. The current stream is the top one."

	| nextChar |
	peekChar ifNil: 
			[nestedStreams ifNotNil: [self checkNestedStream].
			^ nextChar := stream next]
		ifNotNil: 
			[nextChar := peekChar.
			peekChar := nil.
			^ nextChar]
]

{ #category : #tokenizing }
XMLPullParser >> nextCharReference [
	| base charValue |
	self nextChar == $#
		ifFalse: [self errorExpected: 'character reference'].
	base := self peek == $x
		ifTrue: [
			self nextChar.
			16]
		ifFalse: [10].

	charValue := [self readNumberBase: base] on: Error do: [:ex | self errorExpected: 'Number.'].
	(self nextChar) == $;
		ifFalse: [self errorExpected: '";"'].
	^Character value: charValue
]

{ #category : #tokenizing }
XMLPullParser >> nextComment [
	"Skip first -"
	self nextChar.
	self nextChar == $-
		ifFalse: [self errorExpected: 'second comment $-'].
	self nextUpToAll: '-->'.

]

{ #category : #'doc type' }
XMLPullParser >> nextDocType [
	| declType |
	declType := self nextLiteral.
	declType = 'DOCTYPE'
		ifTrue: [
			^self nextUpToAll: '>'].
]

{ #category : #tokenizing }
XMLPullParser >> nextEndTag [
	| string |
	"Skip /"
	self nextChar.
	string := self nextTrimmedBlanksUpTo: $>.
	eventQueue addLast: (XPPEndTag new tag: (XPPTag new name: string))
]

{ #category : #tokenizing }
XMLPullParser >> nextLiteral [
	| resultStream nextChar resultString |
	resultStream := (String new: 10) writeStream.
	((nextChar := self peek) isLetter or: [nextChar == $_]) 
		ifFalse: [self errorExpected: 'Name literal.'].
	
	[nextChar := self peek.
	(LiteralChars at: nextChar asciiValue + 1) 
		ifTrue: 
			[nextChar == $& 
				ifTrue: 
					[nextChar := self nextChar.
					resultStream nextPut: (self peek == $# 
								ifTrue: [self nextCharReference]
								ifFalse: [^ resultStream contents])]
				ifFalse: [resultStream nextPut: self nextChar]]
		ifFalse: 
			[resultString := resultStream contents.
			resultString isEmpty 
				ifTrue: [self errorExpected: 'Name literal']
				ifFalse: [^ resultString]]] 
			repeat
]

{ #category : #tokenizing }
XMLPullParser >> nextName [
	| nextChar |
	nameBuffer reset.
	self peek == $. ifTrue: [self malformedError: 'Character expected.'].
	
	[(nextChar := self peek) ifNil: [self errorExpected: 'Character expected.'].
	NameDelimiters at: nextChar asciiValue] 
			whileFalse: [nameBuffer nextPut: self nextChar].
	^ self fastStreamStringContents: nameBuffer
]

{ #category : #tokenizing }
XMLPullParser >> nextNode [
	| nextChar |
	"Skip < "
	self nextChar.
	nextChar := self peek.
	nextChar == $! ifTrue: [
		"Skip !"
		self nextChar.
		nextChar := self peek.
		nextChar == $- ifTrue: [^self nextComment].
		nextChar == $[ ifTrue: [^self nextCDataOrConditional].
		^self parsingMarkup
			ifTrue: [self nextMarkupDeclaration]
			ifFalse: [self nextDocType]].
	nextChar == $? ifTrue: [^self nextPI].
	^self nextTag
]

{ #category : #tokenizing }
XMLPullParser >> nextPCData [
	| resultStream nextPeek nextChar referenceString entityValue |
	resultStream := (String new: 10) writeStream.
	
	[nextPeek := nextChar := self peek.
	nextChar ifNil: [self errorExpected: 'Character expected.'].
	nextChar == $& 
		ifTrue: 
			[self nextChar.
			self peek == $# 
				ifTrue: 
					[nextPeek := nil.
					nextChar := self nextCharReference]
				ifFalse: 
					[referenceString := self nextLiteral.
					self nextChar == $; ifFalse: [self errorExpected: ';'].
					entityValue := self entity: referenceString.
					(self class isCharEscape: entityValue) 
						ifTrue: 
							[nextPeek := nil.
							nextChar := entityValue]
						ifFalse: 
							[entityValue := entityValue asString.
							entityValue isEmpty 
								ifTrue: [nextPeek := nextChar := nil]
								ifFalse: 
									[self pushStream: (ReadStream on: entityValue asString).
									nextPeek := nextChar := self peek]]]]
		ifFalse: [nextPeek == $< ifFalse: [self nextChar]].
	nextPeek == $<] 
			whileFalse: [nextChar ifNotNil: [resultStream nextPut: nextChar]].
	eventQueue addLast: (XPPText new text: resultStream contents)
]

{ #category : #tokenizing }
XMLPullParser >> nextPI [
	| piTarget piData |
	"Skip ?"
	self nextChar.
	piTarget := self nextLiteral.
	piTarget asUppercase = 'XML'
		ifTrue: [^self nextXMLDecl].
	self skipSeparators.
	piData := self nextUpToAll: '?>'.
	"self handlePI: piTarget data: piData"
]

{ #category : #tokenizing }
XMLPullParser >> nextTag [
	| tagName attributes nextChar namespaces |
	self peek = $/ ifTrue: [^ self nextEndTag].
	tagName := self nextName.
	self skipSeparators.
	attributes := Dictionary new: 33.
	namespaces := Dictionary new: 5.
	[(nextChar := self peek) == $> or: [nextChar == $/]] whileFalse: 
			[self nextAttributeInto: attributes namespaces: namespaces.
			self skipSeparators].
	eventQueue addLast: (XPPStartTag new tag: (XPPTag new name: tagName); attributes: attributes).
	self nextChar == $/ 
		ifTrue: 
			[eventQueue addLast: (XPPEndTag new tag: (XPPTag new name: tagName)).
			self nextChar]
]

{ #category : #streaming }
XMLPullParser >> nextTrimmedBlanksUpTo: delimiter [ 
	| resultStream nextChar |
	resultStream := WriteStream on: (String new: 10).
	nextChar := nil.
	[(nextChar := self nextChar) == delimiter] 
		whileFalse: [nextChar == $  ifFalse: [resultStream nextPut: nextChar]].
	nextChar == delimiter 
		ifFalse: 
			[XPPStructureException raiseSignal: 'XML no delimiting ' , delimiter printString , ' found'].
	^ resultStream contents
]

{ #category : #streaming }
XMLPullParser >> nextUpToAll: delimitingString [ 
	| string |
	self unpeek.
	string := stream upToAll: delimitingString.
	 stream skip: delimitingString size negated.
	( stream next: delimitingString size) = delimitingString 
		ifFalse: 
			[XPPStructureException raiseSignal: 'XML no delimiting ' , delimitingString printString , ' found'].
	^ string
]

{ #category : #tokenizing }
XMLPullParser >> nextWhitespace [
	| nextChar |
	
	[(nextChar := self peek) == nil 
		or: [SeparatorTable at: nextChar asciiValue + 1 ifAbsent: [true]]] 
			whileFalse: [self nextChar].
	(nestedStreams == nil or: [self atEnd not]) 
		ifFalse: 
			[self checkNestedStream.
			self nextWhitespace]
]

{ #category : #tokenizing }
XMLPullParser >> nextXMLDecl [
	| attributes nextChar namespaces |
	self skipSeparators.
	attributes := Dictionary new.
	namespaces := Dictionary new.
	[(nextChar := self peek) == $?] whileFalse: [
		self nextAttributeInto: attributes namespaces: namespaces.
		self skipSeparators.].
	self nextChar.
	self nextChar == $>
		ifFalse: [self errorExpected: '> expected.'].
	(attributes includesKey: 'encoding') ifTrue: [self streamEncoding: (attributes at: 'encoding')].
	"self handleXMLDecl: attributes namespaces: namespaces"
	
]

{ #category : #'initialize-release' }
XMLPullParser >> parse: source [ 
	source isStream 
		ifTrue: [stream := source]
		ifFalse: [stream := source readStream].
	current := XPPStartDocument new
]

{ #category : #private }
XMLPullParser >> parsingMarkup [
	^parsingMarkup
]

{ #category : #streaming }
XMLPullParser >> peek [
	"Return the next character from the current input stream. If the current stream poop to next nesting level if there is one.
	Due to the potential nesting of original document, included documents and replacment texts the streams are held in a stack representing the nested streams. The current stream is the top one."

	peekChar ifNil: 
			[nestedStreams ifNotNil: [self checkNestedStream].
			^ peekChar := stream atEnd ifTrue: [nil] ifFalse: [stream next]]
		ifNotNil: [^ peekChar]
]

{ #category : #private }
XMLPullParser >> readNumberBase: base [
	"Read a hex number from stream until encountering $; "

	| value digit |
	base = 10 ifFalse: [	| numberString | 
		numberString := self nextUpTo: $;.
		self stream skip: -1.
		^Integer readFrom: numberString asUppercase readStream base: base. 
	].

	value := 0.
	digit := DigitTable at: self peek asciiValue.
	digit < 0
		ifTrue: [self error: 'At least one digit expected here'].
	self nextChar.
	value := digit.
	[digit := DigitTable at: self peek asciiValue.
	digit < 0
		ifTrue: [^value]
		ifFalse: [
			self nextChar.
			value := value * base + digit]
		] repeat.
	^ value
]

{ #category : #serializing }
XMLPullParser >> serializeTagContentsTo: serializer [ 
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self consumeEndTag
]

{ #category : #serializing }
XMLPullParser >> serializeTagTo: serializer [ 
	self mustBeStartTag.
	self current serializeTo: serializer.
	self consumeStartTag.
	self serializeUntilEndTagTo: serializer.
	self current serializeTo: serializer.
	self consumeEndTag
]

{ #category : #serializing }
XMLPullParser >> serializeUntilEndTagTo: serializer [ 
	[self isEndTag] whileFalse: 
			[| event |
			event := self current.
			event isText 
				ifTrue: 
					[event serializeTo: serializer.
					self next]
				ifFalse: 
					[event isStartTag 
						ifTrue: [self serializeTagTo: serializer]
						ifFalse: [XPPStructureException raiseSignal: 'Unexpected element']]]
]

{ #category : #'tag-based api' }
XMLPullParser >> skip: tagName [ 
	"Throw an exception if current event isn't a start tag, or doesn't match a supplied tag name. If it succeeds then it consumes the start tag, and all events up to and including the matching end tag, taking correct account of tag nesting. Thus it doesn't stop at the first matching end tag, but rather it keeps a count of the nesting depth."

	self consumeStartTag: tagName.
	[self isEndTag] whileFalse: 
			[| event |
			event := self current.
			event isText 
				ifTrue: [self next]
				ifFalse: 
					[event isStartTag 
						ifTrue: [self skipAny]
						ifFalse: [XPPStructureException raiseSignal: 'Unexpected element']]].
	self consumeEndTag: tagName
]

{ #category : #'tag-based api' }
XMLPullParser >> skipAny [
	"Throw an exception if current event isn't a start tag. If it succeeds then it consumes the start tag, and all events up to and including the matching end tag, taking correct account of tag nesting. Thus it doesn’t stop at the first matching end tag, but rather it keeps a count of the nesting depth."
	self consumeStartTag.
	[self isEndTag] whileFalse: 
			[| event |
			event := self current.
			event isText 
				ifTrue: [self next]
				ifFalse: 
					[event isStartTag 
						ifTrue: [self skipAny]
						ifFalse: [XPPStructureException raiseSignal: 'Unexpected element']]].
	self consumeEndTag
]

{ #category : #'tag-based api' }
XMLPullParser >> skipIf: tagName [ 
	(self is: tagName) ifTrue: [ self skipAny ].
]

{ #category : #'tag-based api' }
XMLPullParser >> skipIfAny [
	self isStartTag ifTrue: [self skipAny]
]

{ #category : #streaming }
XMLPullParser >> skipSeparators [
	| nextChar |
	[((nextChar := self peek) == nil)
		or: [SeparatorTable at: nextChar asciiValue+1]]
		whileFalse: [self nextChar].
	(nestedStreams == nil or: [self atEnd not])
		ifFalse: [
			self checkNestedStream.
			self skipSeparators]
]

{ #category : #tokenizing }
XMLPullParser >> skipUpTo: delimiter [ 
	| nextChar |
	self unpeek.
	[self atEnd or: [(nextChar := self nextChar) == delimiter]] whileFalse: [].
	nextChar == delimiter 
		ifFalse: 
			[XPPStructureException raiseSignal: 'XML no delimiting ' , delimiter printString , ' found']
]

{ #category : #'tag-based api' }
XMLPullParser >> skipWhile: tagName [ 
	[self is: tagName] whileTrue: [self skipAny]
]

{ #category : #'tag-based api' }
XMLPullParser >> skipWhileAny [
	[self isStartTag] whileTrue: [self skipAny]
]

{ #category : #streaming }
XMLPullParser >> streamEncoding: encodingString [

	| converterClass |
	Smalltalk at: #TextConverter ifPresent: [:tc | 
		(stream respondsTo: #converter:) ifTrue: [
			converterClass := tc defaultConverterClassForEncoding: encodingString asLowercase.
			converterClass ifNotNil: [stream converter: converterClass new]]]
]

{ #category : #'delegating accessors' }
XMLPullParser >> tag [
	^self current tag
]

{ #category : #'delegating accessors' }
XMLPullParser >> text [
	^ self isText 
		ifTrue: 
			[| text |
			text := self current text.
			self next.
			text]
		ifFalse: ['']
]

{ #category : #'tag-based api' }
XMLPullParser >> textIf: tagName [
	^self if: tagName take: [self text] else: [ '' ].
]

{ #category : #'tag-based api' }
XMLPullParser >> textIf: tagName else: aBlock [
	^self if: tagName take: [self text] else: [ aBlock value ].
]

{ #category : #'tag-based api' }
XMLPullParser >> textIfAny [
	^self ifAnyTake: [self text] else: [ '' ].
]

{ #category : #'tag-based api' }
XMLPullParser >> textIfAnyElse: aBlock [
	^self ifAnyTake: [self text] else: [ aBlock value ].
]

{ #category : #'tag-based api' }
XMLPullParser >> textOf: tagName [ 
	^self match: tagName take: [self text]
]

{ #category : #'tag-based api' }
XMLPullParser >> textOfAny [
	^self matchAnyTake: [self text]
]

{ #category : #streaming }
XMLPullParser >> unpeek [
	peekChar ifNotNil: 
			[stream pushBack: (String with: peekChar).
			peekChar := nil]
]

{ #category : #private }
XMLPullParser >> usesNamespaces [
	^true
]

{ #category : #'tag-based api' }
XMLPullParser >> while: tagName peek: aBlock [ 
	[self is: tagName] whileTrue: [self matchAnyPeek: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> while: tagName peek: aBlock separatedBy: sepBlock [ 
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
			[doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
			self matchAnyPeek: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> while: tagName take: aBlock [ 
	[self is: tagName] whileTrue: [self matchAnyTake: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> while: tagName take: aBlock separatedBy: sepBlock [ 
	| doneFirst |
	doneFirst := false.
	[self is: tagName] whileTrue: 
			[| tag |
			tag := self current.
			self consumeStartTag.
			doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
			aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
			self consumeEndTag]
]

{ #category : #'tag-based api' }
XMLPullParser >> whileAnyPeek: aBlock [ 
	[self isStartTag] whileTrue: [self matchAnyPeek: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> whileAnyPeek: aBlock separatedBy: sepBlock [ 
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
			[| tag |
			tag := self current.
			doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
			aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value]]
]

{ #category : #'tag-based api' }
XMLPullParser >> whileAnyTake: aBlock [ 
	[self isStartTag] whileTrue: [self matchAnyTake: aBlock]
]

{ #category : #'tag-based api' }
XMLPullParser >> whileAnyTake: aBlock separatedBy: sepBlock [ 
	| doneFirst |
	doneFirst := false.
	[self isStartTag] whileTrue: 
			[| tag |
			tag := self current.
			self consumeStartTag.
			doneFirst ifTrue: [sepBlock value] ifFalse: [doneFirst := true].
			aBlock numArgs = 1 ifTrue: [aBlock value: tag] ifFalse: [aBlock value].
			self consumeEndTag]
]
