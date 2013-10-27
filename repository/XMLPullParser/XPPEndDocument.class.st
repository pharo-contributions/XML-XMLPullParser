"
XPPEndDocument is the event raised when we arrive at the end of a document.
"
Class {
	#name : #XPPEndDocument,
	#superclass : #XPPEvent,
	#category : #XMLPullParser
}

{ #category : #testing }
XPPEndDocument >> isEndDocument [
	^ true
]

{ #category : #serializing }
XPPEndDocument >> serializeTo: serializer [
]
