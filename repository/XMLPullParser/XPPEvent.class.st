"
XPPEvent is the root of the event hierarchy. It is abstract. 
"
Class {
	#name : #XPPEvent,
	#superclass : #Object,
	#category : 'XMLPullParser'
}

{ #category : #testing }
XPPEvent >> isEndDocument [
	^false
]

{ #category : #testing }
XPPEvent >> isEndTag [
	^false
]

{ #category : #testing }
XPPEvent >> isEndTag: aStringOrNodeTag [
	^false
]

{ #category : #testing }
XPPEvent >> isStartDocument [
	^false
]

{ #category : #testing }
XPPEvent >> isStartTag [
	^false
]

{ #category : #testing }
XPPEvent >> isStartTag: aStringOrNodeTag [
	^false
]

{ #category : #testing }
XPPEvent >> isText [
	^false
]
