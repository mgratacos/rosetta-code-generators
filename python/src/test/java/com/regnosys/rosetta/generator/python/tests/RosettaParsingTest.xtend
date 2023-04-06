package com.regnosys.rosetta.generator.python.tests

import com.google.inject.Inject
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.ModelHelper
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith

import org.junit.jupiter.api.Disabled

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)

class RosettaParsingTest {


    @Inject extension ModelHelper modelHelper
    
    
	@Test
	def void testClass() {
	'''
			synonym source FpML
			synonym source FIX
			
			type PartyIdentifier: <"The set of [partyId, PartyIdSource] associated with a party.">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testClassWithEnumReference() {
	'''
			synonym source FpML
			synonym source FIX
			
			type PartyIdentifier: <"Bla">
				partyId string (1..1) <"Bla">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
				partyIdSource PartyIdSourceEnum (1..1)
					[synonym FIX value "PartyIDSource" tag 447]
					[synonym FpML value "PartyIdScheme"]
			
			enum PartyIdSourceEnum:
				LEI <"The Legal Entity Identifier">
				BIC <"The Bank Identifier Code">
				MIC
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testStandards() {
	'''
			synonym source FIX
			synonym source FpML
			synonym source ISO_20022
			
			type BasicTypes: <"">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
					[synonym ISO_20022 value "partyId"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymRefs() {
	'''
			synonym source FIX
			type BasicTypes: <"">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FIX value "PartyID" componentID 448]
					[synonym FIX value "PartyID.value"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testBasicTypes() {
	'''
			type Standards: <"">
				value1 int (0..1) <"">
				value3 number (0..1) <"">
				value5 boolean (0..1) <"">
				value6 date (0..1) <"">
				value9 string (0..1) <"">
				value10 zonedDateTime (0..1) <"">
				value11 productType (0..1) <"">
				value12 eventType (0..1) <"">
				value13 calculation (0..1) <"">
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testEnumRegReferences() {
	'''
			enum PartyIdSourceEnum: <"The enumeration values associated with party identifier sources.">
				LEI <"The ISO 17442:2012 Legal Entity Identifier.">
				BIC <"The Bank Identifier Code.">
				MIC <"The ISO 10383 Market Identifier Code, applicable to certain types of execution venues, such as exchanges.">
				NaturalPersonIdentifier <"The natural person identifier.  When constructed according.">
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testMultipleSynonyms() {
	'''
			synonym source FpML
			synonym source FIX

			type PartyIdentifier: <"The set of [partyId, PartyIdSource] associated with a party.">
				partyId string (1..1) <"The identifier associated with a party, e.g. the 20 digits LEI code.">
					[synonym FIX value "PartyID" tag 448]
					[synonym FpML value "partyId"]
				partyIdSource PartyIdSourceEnum (1..1) <"The reference source for the partyId, e.g. LEI, BIC.">
					[synonym FIX value "PartyIDSource" tag 447]
					[synonym FpML value "PartyIdScheme"]
			enum PartyIdSourceEnum: <"The enumeration values associated with party identifier sources.">
				LEI <"The Legal Entity Identifier">
				BIC <"The Bank Identifier Code">
				MIC <"The ISO 10383 Market Identifier Code, applicable to certain types of execution venues, such as exchanges.">
		'''.parseRosettaWithNoErrors
	}

	@Test
	def void testEnumeration() {
	'''
			synonym source FpML
			synonym source FIX
			
			enum QuoteRejectReasonEnum: <"The enumeration values to qualify the reason as to why a quote has been rejected.">
				UnknownSymbol
					[synonym FIX value "1" definition "foo"]
				ExchangeClosed
					[synonym FpML value "exchangeClosed" definition "foo" pattern "" ""]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testMultipleOrNoAttributeSynonym() {
	'''
			synonym source FIX
			synonym source FpML
			type TradeIdentifier: <"The trade identifier, along with the party that assigned it.">
				[synonym FpML value "partyTradeIdentifier"]
				IdentifyingParty string (1..1) <"The party that assigns the trade identifier">
				tradeId string (1..1) <"In FIX, the unique ID assigned to the trade entity once it is received or matched by the exchange or central counterparty.">
					[synonym FIX value "TradeID" tag 1003]
					[synonym FIX value "SecondaryTradeID" tag 1040]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testDataRuleWithChoice() {
	'''
			type Party:
				foo boolean (1..1)
				bar BarEnum (0..*)
				foobar string (0..1)
				condition Foo_Bar:
					if Party -> foo = True
					then
						if Party -> bar = BarEnum -> abc
							then Party -> foobar exists
						else Party -> foobar is absent
			enum BarEnum:
				abc
				bde
				cer
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testAttributeWithReferenceAnchorAndScheme() {
	'''
			synonym source FpML
			type Foo:
				foo string (1..1)
					[metadata reference]
					[metadata scheme]
					[synonym FpML value "foo" meta "href", "id", "fooScheme"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testChoiceRule() {
	'''
			type Foo:
				foo Color (1..*)
				bar string (0..*)
				condition foo_bar:
					required choice foo, bar
			type Color:
				 blue boolean (0..1)

		'''.parseRosettaWithNoErrors	
	}
			
	@Test
	def void testAttributeWithMetadataReferenceAnnotation() {
		'''
			metaType reference string
			
			type Foo:
				foo string (1..1)
					[metadata reference]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributeWithMetadataIdAnnotation() {
	'''
			metaType id string

			type Foo:
				foo string (1..1)
					[metadata id]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributeWithMetadataSchemeAnnotation() {
	'''
			metaType scheme string
			metaType reference string

			type Foo:
				foo string (1..1) 
					[metadata scheme]
			
			type Bar:
				bar string (1..1)
					[metadata scheme]
					[metadata reference]
			
		'''.parseRosettaWithNoErrors	
	}
	
	@Test
	def void testAttributesWithLocationAndAddress() {
	'''
			metaType scheme string
			metaType reference string

			type Foo:
				foo string (1..1) 
					[metadata location]
			
			type Bar:
				bar string (1..1)
					[metadata address "pointsTo"=Foo->foo]
			
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymsWithPathExpression() {
		'''
			synonym source FpML
			type Foo:
				foo int (0..1)
					[synonym FpML value "foo" path "fooPath1"]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void synonymsWithHint() {
		'''
			synonym source FpML
			type Foo:
				foo int (0..1)
					[synonym FpML hint "myHint"]
		'''.parseRosettaWithNoErrors
	}
		
	@Test
	def void testSynonymMappingSetToBoolean() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
					[synonym FpML set to True when "FooSyn" exists]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetToString() {
		'''
			synonym source FpML
			type Foo:
				foo string (0..1)
					[synonym FpML set to "A" when "FooSyn" exists]
			
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetToEnum() {
		'''
			synonym source FpML
			type Foo:
				foo BarEnum (0..1)
					[synonym FpML set to BarEnum -> a when "FooSyn" exists]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingDefaultToEnum() {
		'''
			synonym source FpML
			type Foo:
				foo BarEnum (0..1)
					[synonym FpML value "FooSyn" default to BarEnum -> a]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenEqualsCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
					[synonym FpML value "FooSyn" set when "path->to->string" = BarEnum -> a]
			
			enum BarEnum:
				a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenExistsCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
				[synonym FpML value "FooSyn" set when "path->to->string" exists]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingSetWhenIsAbsentCondition() {
		'''
			synonym source FpML
			type Foo:
				foo boolean (0..1)
				[synonym FpML value "FooSyn" set when "path->to->string" is absent]
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testSynonymMappingMultipleSetToWhenConditions() {
		'''
			synonym source FpML
			type Foo:
				foo string (0..1)
					[synonym FpML
							set to "1" when "path->to->string" = "Foo",
							set to "2" when "path->to->enum" = BarEnum -> a,
							set to "3" when "path->to->string" is absent,
							set to "4"]

			enum BarEnum: a b
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void testClassSynonym() {
	'''
			synonym source FpML
			
			type Foo:
				[synonym FpML value "FooSyn"]
				bar boolean (1..1)
			
		'''.parseRosettaWithNoErrors
	}

	@Test @Disabled //FIXME support "and Foo_Bar apply" ?
	def void testIsProduct() {
	'''
			isProduct FooBar
				[synonym Bank_A value "Foo_Bar"]
				[synonym Venue_B value "BarFoo"]
				Foo -> foo exists
					and ( Foo -> bar is absent
						or Foo -> foo <> Foo -> foo  )
				and Foo_Bar apply
				
			type Foo:
				foo string (1..1)
				bar Bar (0..1)
				condition Foo_Bar:
					if foo exists
						then Foo is absent
			
			type Bar:
				bar string (1..1)

		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithMapperShouldParseWithNoErrors() {
	'''
			type Foo:
				foo string (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" mapper "BarToFooMapper"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithFormatShouldParseWithNoErrors() {
	'''
			type Foo:
				foo date (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" dateFormat "MM/dd/yy"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithPattenShouldParseWithNoErrors() {
	 '''
			type Foo:
				foo int (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" pattern "([0-9])*.*" "$1"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalEnumSynonymWithPattenShouldParseWithNoErrors() {
	'''
			enum Foo:
				FOO
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
			enums	
				Foo:
					+ FOO
						[value "bar" pattern "([0-9])*.*" "/$1"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithMetaShouldParseWithNoErrors() {
	'''
			metaType scheme string
			
			type Foo:
				foo string (0..1)
				[metadata scheme]
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" path "baz" meta "barScheme"]
			}
		'''.parseRosettaWithNoErrors
	}
	
	@Test
	def void externalSynonymWithRemoveHtmlShouldParseWithNoErrors() {
	'''
			type Foo:
				foo string (0..1)
			
			synonym source TEST_Base
			
			synonym source TEST extends TEST_Base {
				
				Foo:
					+ foo
						[value "bar" removeHtml]
			}
		'''.parseRosettaWithNoErrors
	}
	
}