"
XPPTagEvent is the event raised when we arrive on a tag.
"
Class {
	#name : #XPPTagEvent,
	#superclass : #XPPEvent,
	#instVars : [
		'tag'
	],
	#category : 'XMLPullParser'
}

{ #category : #'instance creation' }
XPPTagEvent class >> tag: tag [ 
	^self new tag: tag
]

{ #category : #accessing }
XPPTagEvent >> is: tagName [ 
	^ tag isLike: tagName
]

{ #category : #accessing }
XPPTagEvent >> name [
	^ tag name
]

{ #category : #accessing }
XPPTagEvent >> namespace [
	^ tag namespace
]

{ #category : #accessing }
XPPTagEvent >> qualifier [
	^ tag qualifier
]

{ #category : #accessing }
XPPTagEvent >> tag [
	^ tag
]

{ #category : #accessing }
XPPTagEvent >> tag: aNodeTag [ 
	tag := aNodeTag
]

{ #category : #accessing }
XPPTagEvent >> type [
	^ tag type
]
