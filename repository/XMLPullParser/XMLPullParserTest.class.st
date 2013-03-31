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
