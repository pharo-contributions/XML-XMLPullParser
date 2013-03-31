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
