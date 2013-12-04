"
<document>
  <tagA a1='att1' a2='att2'>blah</tagA>
  <tagB>aaa<tagC>bbb</tagC>ccc</tagB>
</document>

would be converted to the follow steam of tokens:

StartDocument
  StartTag{document,[]}
    StartTag{tagA,[Attribute{a1,'att1'},Attribute{a2,'att2'}]}
      Text{'blah'}
    EndTag{tagA}
    StartTag{tagB, []}
      Text{'aaa'}
      StartTag{tagC, []}
        Text{'bbb'}
      EndTag{tagC}
      Text{'ccc'}
    EndTag{tagB}
  EndTag{document}
EndDocument
"
Class {
	#name : #XPPStartTag,
	#superclass : #XPPTagEvent,
	#instVars : [
		'attributes'
	],
	#category : 'XMLPullParser'
}

{ #category : #'instance creation' }
XPPStartTag class >> tag: tag attributes: a [ 
	^(super tag: tag) attributes: a
]

{ #category : #accessing }
XPPStartTag >> at: attName [ 
	^ self at: attName
		ifNone: 
			[XPPStructureException 
				raiseSignal: 'Expected attribute ' , attName , ' is missing']
]

{ #category : #accessing }
XPPStartTag >> at: attName ifFound: aFoundBlock ifNone: aBlock [ 
	attributes 
		keysAndValuesDo: [:a :value | (a = attName) ifTrue: [^ aFoundBlock value: value]].
	^ aBlock value
]

{ #category : #accessing }
XPPStartTag >> at: attName ifNone: aBlock [ 
	^attributes at: attName asString ifAbsent: [aBlock value]

]

{ #category : #accessing }
XPPStartTag >> attributes [
	^ attributes
]

{ #category : #accessing }
XPPStartTag >> attributes: anObject [ 
	attributes := anObject
]

{ #category : #testing }
XPPStartTag >> isStartTag [
	^ true
]

{ #category : #testing }
XPPStartTag >> isStartTag: aStringOrNodeTag [ 
	^ tag isLike: aStringOrNodeTag
]

{ #category : #printing }
XPPStartTag >> printOn: aStream [ 
	super printOn: aStream.
	aStream
		nextPutAll: ' <';
		nextPutAll: tag asString;
		nextPutAll: '>'
]

{ #category : #serializing }
XPPStartTag >> serializeTo: serializer [ 
	serializer 
		startElement: tag namespace
		localName: tag type
		qName: tag asString
		attributes: attributes
]
