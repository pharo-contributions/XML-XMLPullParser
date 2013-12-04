"
<document>
  <tagA a1='att1' a2='att2'>blah</tagA>
  <tagB>aaa<tagC>bbb</tagC>ccc</tagB>
</document>

would be converted to the follow steam of tokens:

StartDocument
  StartTag{document,[]}
    StartTag{tagA,[Attribute{a1,'att1'},Attribute{a2,'att2'}]}
      Text{'blah'}
    EndTag{tagA}
    StartTag{tagB, []}
      Text{'aaa'}
      StartTag{tagC, []}
        Text{'bbb'}
      EndTag{tagC}
      Text{'ccc'}
    EndTag{tagB}
  EndTag{document}
EndDocument
"
Class {
	#name : #XPPText,
	#superclass : #XPPEvent,
	#instVars : [
		'text'
	],
	#category : 'XMLPullParser'
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
