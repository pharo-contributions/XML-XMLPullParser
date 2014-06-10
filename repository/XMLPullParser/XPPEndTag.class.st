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
	#name : #XPPEndTag,
	#superclass : #XPPTagEvent,
	#category : #XMLPullParser
}

{ #category : #testing }
XPPEndTag >> isEndTag [
	^ true
]

{ #category : #testing }
XPPEndTag >> isEndTag: aStringOrNodeTag [ 
	^ tag isLike: aStringOrNodeTag
]

{ #category : #printing }
XPPEndTag >> printOn: aStream [ 
	super printOn: aStream.
	aStream
		nextPutAll: ' </';
		nextPutAll: tag asString;
		nextPutAll: '>'
]

{ #category : #serializing }
XPPEndTag >> serializeTo: serializer [ 
	serializer 
		endElement: tag namespace
		localName: tag type
		qName: tag asString
]
