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
