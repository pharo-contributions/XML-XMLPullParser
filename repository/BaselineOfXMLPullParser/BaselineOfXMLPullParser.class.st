Class {
	#name : #BaselineOfXMLPullParser,
	#superclass : #BaselineOf,
	#category : #BaselineOfXMLPullParser
}

{ #category : #baseline }
BaselineOfXMLPullParser >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			spec blessing: #baseline.
			spec
				package: 'XMLPullParser';
				group: 'default' with: #('XMLPullParser') ]
]
