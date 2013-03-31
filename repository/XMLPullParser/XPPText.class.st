Class {
	#name : #XPPText,
	#superclass : #XPPEvent,
	#instVars : [
		'text'
	],
	#category : #XMLPullParser
}

{ #category : #'instance creation' }
XPPText class >> text: aString [ 
	^self new text: aString
]

{ #category : #testing }
XPPText >> isText [
	^ true
]

{ #category : #serializing }
XPPText >> serializeTo: serializer [ 
	serializer 
		characters: text
		from: 1
		to: text size
]

{ #category : #accessing }
XPPText >> text [
	^ text
]

{ #category : #accessing }
XPPText >> text: aString [ 
	text := aString
]
