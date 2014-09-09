Class {
	#name : #XMLPullParserTest,
	#superclass : #TestCase,
	#category : #XMLPullParser
}

{ #category : #testing }
XMLPullParserTest >> testCDATA [
	| parser |
	parser := XMLPullParser parse: '<document><![CDATA[This is a test & stuff in here doesn''t have to be escaped]]></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: parser next isText.
	self assert: parser text = 'This is a test & stuff in here doesn''t have to be escaped'.
	self assert: (parser isEndTag: 'document').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testCharacterReferences [
	| parser |
	parser := XMLPullParser parse: '<document><name>&#35;&#40;&amp;&#41;</name></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'name').
	self assert: parser next isText.
	self assert: parser text = '#(&)'.
	self assert: (parser isEndTag: 'name').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testDecimalEntity [
	| parser |
	
	parser := XMLPullParser parse: '
		<tag contents="one&#10;two" />'.
	
	self assert: (parser next at: #contents) equals: (Character lf join: #(one two))
]

{ #category : #testing }
XMLPullParserTest >> testDoubleTag [
	| parser |
	parser := XMLPullParser parse: '<document><body></body></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'body').
	self assert: (parser next isEndTag: 'body').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testEmpty [
	| parser |
	parser := XMLPullParser parse: ''.
	self assert: parser isStartDocument.
	self assert: parser next isEndDocument.
]

{ #category : #testing }
XMLPullParserTest >> testEscapes [
	| parser |
	parser := XMLPullParser parse: '<tag>Escaped &amp; Unescaped: &lt;&gt;</tag>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'tag').
	self assert: parser next isText.
	self assert: (parser text = 'Escaped & Unescaped: <>').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testHexEntity [
	| parser |
	
	parser := XMLPullParser parse: '
		<tag contents="one&#xA;two" />'.
	
	self assert: (parser next at: #contents) equals: (Character lf join: #(one two))
]

{ #category : #testing }
XMLPullParserTest >> testIncludesTag [

	| parser tagCollection  |

	parser := XMLPullParser parse: '<document><body></body></document>'.
	tagCollection :=  { 'body' }.
	[ parser atEnd not and: [ (parser includesTag: tagCollection) not]  ]
		whileTrue: [ parser next ].
	self assert: (parser includesTag: tagCollection).

]

{ #category : #testing }
XMLPullParserTest >> testIsTag [
	| parser |
	parser := XMLPullParser parse: '
<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	self assert: parser isStartDocument.
	self assert: parser next isTag. " 'person' "
	self assert: parser next isTag. " 'name' "
	self deny: parser next isTag.
	self assert: parser next isTag. " '/name' "
	self assert: parser next isTag. " 'notedFor' "
	self deny: parser next isTag.
	self assert: parser next isTag. " '/notedFor' "
	self assert: parser next isTag. " '/person' "
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testParsingError [

	self should: [(XMLPullParser parse: '<body') next] raise: XPPStructureException
]

{ #category : #testing }
XMLPullParserTest >> testPeekText [
	| parser |
	parser := XMLPullParser parse: '
<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	self assert: parser isStartDocument.
	parser next.
	self assert: parser peekText = ''. "person"
	parser next.
	self assert: parser peekText = ''. "name"
	parser next.
	self assert: parser peekText = 'Kent Beck'.
	parser next.
	self assert: parser peekText = ''. "/name"
	parser next.
	self assert: parser peekText = ''. "notedFor"
	parser next.
	self assert: parser peekText = 'XP'.
	parser next.
	self assert: parser peekText = ''. "/notedFor"
	parser next.
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testPerson [
	| parser |
	parser := XMLPullParser 
				parse: '
<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'person').
	self assert: (parser current attributes at: 'id') = '27'.
	self assert: (parser next isStartTag: 'name').
	self assert: parser next isText.
	self assert: parser text = 'Kent Beck'.
	self assert: (parser next isStartTag: 'notedFor').
	self assert: parser next isText.
	self assert: parser text = 'XP'.
	self assert: (parser next isEndTag: 'person').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testSingleSelfClosingTag [
	| parser |
	parser := XMLPullParser parse: '<selfClose />'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'selfClose').
	self assert: parser next isEndTag.
	self assert: parser next isEndDocument.
]

{ #category : #testing }
XMLPullParserTest >> testSingleTag [
	| parser |
	parser := XMLPullParser parse: '<document><body></body></document>'.
	self assert: parser isStartDocument.
	self assert: (parser next isStartTag: 'document').
	self assert: (parser next isStartTag: 'body').
	self assert: (parser next isEndTag: 'body').
	self assert: (parser next isEndTag: 'document').
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testTagName [
	| parser |
	parser := XMLPullParser parse: '
<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	self assert: parser isStartDocument.
	parser next.
	self assert: (parser tagName = 'person').
	parser next.	
	self assert: (parser tagName = 'name').
	parser next.
	self should: [ parser tagName ] raise: MessageNotUnderstood.
	self assert: parser text = 'Kent Beck'.
	parser next.
	self assert: (parser tagName = 'notedFor').
	parser next.
	self should: [ parser tagName ] raise: MessageNotUnderstood.
	parser next.
	self assert: parser next isEndTag.
	self assert: parser next isEndDocument
]

{ #category : #testing }
XMLPullParserTest >> testTextExtractionFirstLevel [
	"self debug:#testTextExtractionFirstLevel"
	
	| xpp  output |
	xpp := XMLPullParser parse: '<document>
  <tagA a1=''att1'' a2=''att2''>blah</tagA>
  <tagB>aaa<tagC>bbb</tagC>ccc</tagB>
</document>'.
      output := String new writeStream.
  	[ xpp next isEndDocument ] whileFalse: [
   	    xpp isText ifTrue: [ output nextPutAll: xpp text ]].
  	self assert: output contents equals: 'blahaaabbbccc'. 
	
]

{ #category : #testing }
XMLPullParserTest >> testTextExtractionFirstLevel2 [
	"self debug:#testTextExtractionFirstLevel2"
	
	| xpp  output |
	xpp := XMLPullParser parse: '<person id="27">
	<!-- Comment -->
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>'.
      output := String new writeStream.
  	[ xpp next isEndDocument ] whileFalse: [
   	    xpp isText ifTrue: [ output nextPutAll: xpp text ]].
  	 self assert: output contents  equals: 'Kent BeckXP'
]

{ #category : #testing }
XMLPullParserTest >> testTextWhileNotTag [
	| parser myFinalTag nodes |
	parser := XMLPullParser parse: '
<person id="27">
	<!-- Comment -->
	<attNode1></attNode1>
	<attNode2></attNode2>
	<id>27</id>
	<name>Kent Beck</name>
	<notedFor>XP</notedFor>
</person>
'.
	myFinalTag :=  'notedFor'.
	nodes := OrderedCollection new.
	self assert: parser isStartDocument.
	[ parser isStartTag: myFinalTag ] whileFalse: [ | text |
		parser next.
		(text := parser textWhileNotTag: myFinalTag) notNil ifTrue: [ nodes add: text ] ].
	self assert: (parser isStartTag: myFinalTag).
	self assert: nodes notEmpty.
	self assert: (nodes hasEqualElements: {'id' ->'27' . 'name'->'Kent Beck'}).

	
]
