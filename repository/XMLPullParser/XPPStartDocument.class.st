Class {
	#name : #XPPStartDocument,
	#superclass : #XPPEvent,
	#category : #XMLPullParser
}

{ #category : #testing }
XPPStartDocument >> isStartDocument [
	^ true
]

{ #category : #serializing }
XPPStartDocument >> serializeTo: serializer [ 
	serializer startDocument
]
