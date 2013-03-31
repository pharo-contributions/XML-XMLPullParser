Class {
	#name : #XPPTag,
	#superclass : #Object,
	#instVars : [
		'name'
	],
	#category : #XMLPullParser
}

{ #category : #testing }
XPPTag >> isLike: aString [
	^name = aString
]

{ #category : #accessing }
XPPTag >> name [
	^ name
]

{ #category : #accessing }
XPPTag >> name: anObject [
	name := anObject
]

{ #category : #testing }
XPPTag >> printOn: aStream [
	aStream nextPutAll: '{', name, '}'
]
