"
XPPStartDocument is the event raised when we arrive at the start of a document.
"
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
