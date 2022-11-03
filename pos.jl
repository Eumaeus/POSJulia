### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# ╔═╡ 479731d6-56c7-11ed-3d83-37e9758cdc15
begin
	using Unicode
	using PolytonicGreek
	using SplitApplyCombine
	using CitableBase
	using CitableText
	using CitableCorpus
	using CitableObject
	using EzXML
end

# ╔═╡ 541b8358-6627-4291-beae-ae7a9781cd1d
md"""#### Set up and do a little testing on loading an XML Syntax file"""

# ╔═╡ e9c18ab6-a578-419e-a4ee-cd580e462190
iliadTBString = read("treebanks/iliad_all.xml", String)

# ╔═╡ d622a77c-e757-4fc6-ae9f-8bcede5a8b79
iliadXML = parsexml(iliadTBString)

# ╔═╡ ec72dfd6-21dc-488d-8e07-3fdaec0fc71e
tbRoot = root(iliadXML)

# ╔═╡ 8c53f66d-b34b-40ab-a018-c5e8f060c1b3
iliadSents = findall("//sentence", iliadXML)

# ╔═╡ 4ae34040-4461-4449-aebc-7fd19a31075d
println(length(iliadSents))

# ╔═╡ 01d07b3d-913d-4e17-86c2-a674c37075d3
md"""#### We create a basic `struct` to hold the versions of a pos-element we want"""

# ╔═╡ 3ccd1d56-ae8d-403e-a607-dc8d5bf30fbf
Base.@kwdef mutable struct MorphRecord
	posTag::String = ""
	short::String = ""
	long::String = ""
	urnString::String = ""
end

# ╔═╡ 82b12b4b-0181-4c7f-909f-fa6e5b571eac
md""" 

**Overriding Equality!** The two functions below are necessary for us to compare `MorphRecord` objects. 

"""

# ╔═╡ d9d5abfa-ece4-461d-afc2-9eed0be6ca11
function Base.:(==)(mr1::MorphRecord, mr2::MorphRecord)
	if ((mr1.posTag == mr2.posTag) &&
		(mr1.short == mr2.short) &&
		(mr1.long == mr2.long) &&
		(mr1.urnString == mr2.urnString))
	
		true
	else
		false
	end
end


# ╔═╡ 75f46ebc-c630-48e2-806c-9b3f8d2a352d
function isequal(mr1::MorphRecord, mr2::MorphRecord)
	if ((mr1.posTag == mr2.posTag) &&
		(mr1.short == mr2.short) &&
		(mr1.long == mr2.long) &&
		(mr1.urnString == mr2.urnString) 
	)
	
		true
	else
		false
	end
	
end

# ╔═╡ a5f682d3-310a-450f-b9d1-bec8e10ab1f9
md"""#### Let's set up some constants here, which we can use repeatedly"""

# ╔═╡ f308d263-7659-42ef-8f0d-5fff3eb7f46f
begin
	# Null values
	const nullUrn = Cite2Urn("urn:cite2:fuFolio:uh.2022:null")
	const emptyMorphRecord = MorphRecord("", "", "", "")

	# Keeping track of indices for POStag parts
	posNum = 1
	personNum = 2
	numberNum = 3
	tenseNum = 4
	moodNum = 5
	voiceNum = 6
	genderNum = 7
	caseNum = 8
	degreeNum = 9

	nothing
end

# ╔═╡ 6f551698-630e-4145-ac9e-4ef4f01872ad
md""" ### Morphology Struct
"""

# ╔═╡ 92844bb9-7a2e-4e43-920c-942ec9ccede8
md"""
We make a Struct for morphology, with default value as `emptyMorphRecord`, since no form is going to have *all* properties.
"""

# ╔═╡ 701abf20-ca37-443c-99e6-6b06368fc8db
Base.@kwdef mutable struct Morphology
	pos::MorphRecord = emptyMorphRecord
	person::MorphRecord = emptyMorphRecord
	number::MorphRecord = emptyMorphRecord
	voice::MorphRecord = emptyMorphRecord
	mood::MorphRecord = emptyMorphRecord
	tense::MorphRecord = emptyMorphRecord
	gender::MorphRecord = emptyMorphRecord
	grammaticalCase::MorphRecord = emptyMorphRecord
	degreeMorphRecord = emptyMorphRecord
end

# ╔═╡ 4d5bd156-1c82-4be2-bbff-06a82a03b9d2
md"""### Serialization Functions"""

# ╔═╡ 708af3d9-64fd-440c-9e21-68b11bccb6e2
begin
	
	import Base.string

	function posTag(mr::MorphRecord)
		if (mr.posTag == "")
			"-"
		else
			mr.posTag
		end
	end

	function string(mr::MorphRecord)
		if (mr.long == "")
			""
		else
			mr.long
		end
	end

	
	function string(m::Morphology)
		mvs = [string(m.pos), string(m.person), string(m.number), string(m.voice), string(m.mood), string(m.tense), string(m.gender), string(m.grammaticalCase), string(m.degreeMorphRecord)]

		noblanks = filter(mvs) do s
			length(s) > 0
		end


		join(noblanks, ", ")
		
	end

	function posTag(m::Morphology)
		mvs = [posTag(m.pos), posTag(m.person), posTag(m.number), posTag(m.voice), posTag(m.mood), posTag(m.tense), posTag(m.gender), posTag(m.grammaticalCase), posTag(m.degreeMorphRecord)]

		join(mvs)

	end
	
end

# ╔═╡ e469bce0-ee49-4d90-9ea1-3c4038d5a45b
join(["a", "b", "c", "d"], ", ")

# ╔═╡ 7c324144-b406-45e0-9cb4-288b7f46ab05
md"""### Let's test our Struct!"""

# ╔═╡ ed5cca09-5623-4aab-a909-e371b47e086a
md"""
A noun has a `pos` (as will every form), and `number`, `gender`, and `case`. Nothing else, but because we assigned default values to our `Morphology` struct, we don't need to specify anything else.
"""

# ╔═╡ 911f1494-ca73-4ac0-9e90-b228ffc6080e
menin = Morphology(
	pos = MorphRecord(posTag = "n", short = "noun", long = "noun"),
	number= MorphRecord(posTag = "s", short = "sing", long = "singular"),
	gender = MorphRecord(posTag = "f", short = "fem", long = "feminine"),
	grammaticalCase = MorphRecord(posTag = "a", short = "acc", long = "accusative")
)

# ╔═╡ d1fc518d-b93d-4e88-b849-f778911808f3
string(menin)

# ╔═╡ 8dafac49-daa3-407a-9f2a-1c083a0bef9e
posTag(menin) == "n-s---fa-"

# ╔═╡ ebfed8d2-94c6-4865-889f-9b3e9239f0b4
md"""
## Parse POSTag
"""

# ╔═╡ 2dd0bb77-7e7d-4189-a7d2-674b221630c7
md"""
Accept a POSTag; split it; treat each of the nine parts.
"""

# ╔═╡ 062b19c9-4dcd-4784-bbd1-18df5de5a330
begin
function getPos(s::String)
	posDict = Dict(
		# Part of Speech
		"l" => MorphRecord("l", "art", "article", "urn:cite2:fuGreekMorph:pos.2022:article"),
		"n" => MorphRecord("n", "noun", "noun", "urn:cite2:fuGreekMorph:pos.2022:noun"),
		"a" => MorphRecord("a", "adj", "adjective", "urn:cite2:fuGreekMorph:pos.2022:adjective"),
		"p" => MorphRecord("p", "pron", "pronoun", "urn:cite2:fuGreekMorph:pos.2022:pronoun"),
		"v" => MorphRecord("v", "vb", "verb", "urn:cite2:fuGreekMorph:pos.2022:verb"),
		"d" => MorphRecord("d", "adv", "adverb", "urn:cite2:fuGreekMorph:pos.2022:adverb"),
		"r" => MorphRecord("r", "prep", "preposition", "urn:cite2:fuGreekMorph:pos.2022:preposition"),
		"c" => MorphRecord("c", "conj", "conjunction", "urn:cite2:fuGreekMorph:pos.2022:conjunction"),
		"i" => MorphRecord("i", "inter", "interjection", "urn:cite2:fuGreekMorph:pos.2022:interjection"),
		"u" => MorphRecord("u", "punc", "punctuation", "urn:cite2:fuGreekMorph:pos.2022:punctuation"),
		"g" => MorphRecord("g", "partic", "particle", "urn:cite2:fuGreekMorph:pos.2022:particle"),
		"x" => MorphRecord("x", "irr", "irregular", "urn:cite2:fuGreekMorph:pos.2022:irregular"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getPerson(s::String)
	posDict = Dict(
		# Person
		"1" => MorphRecord("1", "1st", "1st person", "urn:cite2:fuGreekMorph:person.2022:1"),
		"2" => MorphRecord("2", "2nd", "2nd person", "urn:cite2:fuGreekMorph:person.2022:2"),
		"3" => MorphRecord("3", "3rd", "3rd person", "urn:cite2:fuGreekMorph:person.2022:3"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getNumber(s::String)
	posDict = Dict(
		# Number
		"s" => MorphRecord("s", "sing", "singular", "urn:cite2:fuGreekMorph:number.2022:singular"),
		"d" => MorphRecord("d", "dl", "dual", "urn:cite2:fuGreekMorph:number.2022:plural"),
		"p" => MorphRecord("p", "pl", "plural", "urn:cite2:fuGreekMorph:number.2022:dual"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getVoice(s::String)
	posDict = Dict(
		# Voice
		"a" => MorphRecord("a", "act", "active", "urn:cite2:fuGreekMorph:voice.2022:active"),
		"m" => MorphRecord("m", "mid", "middle", "urn:cite2:fuGreekMorph:voice.2022:middle"),
		"p" => MorphRecord("p", "pass", "passive", "urn:cite2:fuGreekMorph:voice.2022:passive"),
		"e" => MorphRecord("e", "m/p", "medio-passive", "urn:cite2:fuGreekMorph:voice.2022:mediopassive"),
		"d" => MorphRecord("d", "dep", "deponent", "urn:cite2:fuGreekMorph:voice.2022:deponent"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getMood(s::String)
	posDict = Dict(
		# Mood
		"i" => MorphRecord("i", "indic", "indicative", "urn:cite2:fuGreekMorph:mood.2022:indicative"),
		"s" => MorphRecord("s", "subj", "subjunctive", "urn:cite2:fuGreekMorph:mood.2022:subjunctive"),
		"n" => MorphRecord("n", "inf", "infinitive", "urn:cite2:fuGreekMorph:mood.2022:infinitive"),
		"m" => MorphRecord("m", "imp", "imperative", "urn:cite2:fuGreekMorph:mood.2022:imperative"),
		"p" => MorphRecord("p", "part", "participle", "urn:cite2:fuGreekMorph:mood.2022:participle"),
		"o" => MorphRecord("o", "opt", "optative", "urn:cite2:fuGreekMorph:mood.2022:optative"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getTense(s::String)
	posDict = Dict(
		# Tense
		"p" => MorphRecord("p", "pres", "present", "urn:cite2:fuGreekMorph:tense.2022:present"),
		"i" => MorphRecord("i", "imperf", "imperfect", "urn:cite2:fuGreekMorph:tense.2022:imperfect"),
		"e" => MorphRecord("r", "perf", "perfect", "urn:cite2:fuGreekMorph:tense.2022:perfect"),
		"l" => MorphRecord("l", "plupf", "pluperfect", "urn:cite2:fuGreekMorph:tense.2022:pluperfect"),
		"t" => MorphRecord("t", "futpf", "future perfect", "urn:cite2:fuGreekMorph:tense.2022:futureperfect"),
		"f" => MorphRecord("f", "fut", "future", "urn:cite2:fuGreekMorph:tense.2022:future"),
		"a" => MorphRecord("a", "aor", "aorist", "urn:cite2:fuGreekMorph:tense.2022:aorist"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getGender(s::String)
	posDict = Dict(
		# Gender
		"m" => MorphRecord("m", "masc", "masculine", "urn:cite2:fuGreekMorph:gender.2022:masculine"),
		"f" => MorphRecord("f", "fem", "feminine", "urn:cite2:fuGreekMorph:gender.2022:feminine"),
		"n" => MorphRecord("n", "neu", "neuter", "urn:cite2:fuGreekMorph:gender.2022:neuter"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getCase(s::String)
	posDict = Dict(
		# Case
		"n" => MorphRecord("n", "nom", "nominative", "urn:cite2:fuGreekMorph:case.2022:nominative"),
		"g" => MorphRecord("g", "gen", "genitive", "urn:cite2:fuGreekMorph:case.2022:genitive"),
		"d" => MorphRecord("d", "dat", "dative", "urn:cite2:fuGreekMorph:case.2022:dative"),
		"a" => MorphRecord("a", "acc", "accusative", "urn:cite2:fuGreekMorph:case.2022:accusative"),
		"v" => MorphRecord("v", "voc", "vocative", "urn:cite2:fuGreekMorph:case.2022:vocative"),
		"l" => MorphRecord("l", "loc", "locative", "urn:cite2:fuGreekMorph:case.2022:locative"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

function getDegree(s::String)
	posDict = Dict(
		# Degree
		"p" => MorphRecord("p", "pos", "positive", "urn:cite2:fuGreekMorph:degree.2022:positive"),
		"c" => MorphRecord("c", "comp", "comparative", "urn:cite2:fuGreekMorph:degree.2022:comparative"),
		"s" => MorphRecord("s", "sup", "superlative", "urn:cite2:fuGreekMorph:degree.2022:superlative"),
		"-" => emptyMorphRecord
	)

	try 
		if (s in keys(posDict)) 
			posDict[s]
		else 
			println(""" "$s" is not a valid value. The valid values are $(keys(posDict)).""")
		end
	catch e
		println(e)
	end
	
end

end


# ╔═╡ da1c838b-510f-4c9e-8d11-1a6574ab3c3b
function getMorphology(pt::String)
	try

		ptArray = map( c -> string(c), split(pt, ""))

		
		Morphology(
			getPos(ptArray[posNum]),
			getPerson(ptArray[personNum]),
			getNumber(ptArray[numberNum]),
			getVoice(ptArray[voiceNum]),
			getMood(ptArray[moodNum]),
			getTense(ptArray[tenseNum]),
			getGender(ptArray[genderNum]),
			getCase(ptArray[caseNum]),
			getDegree(ptArray[degreeNum])
		)
		
		
			
	catch e
		println(e)
		# println(""" "$pt" must have 9 characters; it has $(length(pt)) characters.""")
	end

	
end

# ╔═╡ 92650cb0-447f-4669-900d-e9e298e8daa6


# ╔═╡ fbc8bc36-c4fb-472a-8156-14c275622f94
md"""
We need a selection of POSTags to work with. We'll take them from the first lines of the *Iliad*.
"""

# ╔═╡ e34bf2d0-0f83-4dbc-b14a-87ae9ae47497
begin
	pt1 = "n-s---fa-" # μῆνιν
	pt2 = "v2spma---" # ἄειδε
	pt3 = "n-s---fv-" # θεὰ
	pt4 = "a-s---fa-" # οὐλομένην
	pt5 = "u--------" # ',' (comma)
	pt6 = "v3siie---" # ἐτελείετο
	pt7 = "a-s---mnc" # σαώτερος
	pt8 = "v-sappmn-" # χολωθεὶς
	pt9 = "v3saia---" # ὄρσε
	pt10 = "v-sfpmmn-" # λυσόμενός
	pt11 = "g--------" # τε
	pt12 = "p-s---mg-" # οὗ 
end

# ╔═╡ e7a0413c-8eae-4df8-b67b-3742a1c3d3ab
# "n-s---fa-" # μῆνιν
string(getMorphology(pt1))

# ╔═╡ 3c43456d-3db2-472a-9685-cabc0b704701
# "v2spma---" # ἄειδε
string(getMorphology(pt2))

# ╔═╡ 88c31b4a-5197-40ef-95c7-e428796794b8
# "n-s---fv-" # θεὰ
string(getMorphology(pt3))

# ╔═╡ 96c14b07-a54b-4651-b554-225cada43ccb
# "a-s---fa-" # οὐλομένην
string(getMorphology(pt4))

# ╔═╡ 9bed6a4a-8714-46a1-94c9-8afccae03c58
# "u--------" # ',' (comma)
string(getMorphology(pt5))

# ╔═╡ 878bc6d4-02bc-4205-a6fe-92eb19264929
# "v3siie---" # ἐτελείετο
string(getMorphology(pt6))

# ╔═╡ dfc7f862-09af-41dc-a8f2-8c0724dc0056
# "a-s---mnc" # σαώτερος
string(getMorphology(pt7))

# ╔═╡ 5d292d9c-3543-45be-a81a-928aa565717f
# "v-sappmn-" # χολωθεὶς
string(getMorphology(pt8))

# ╔═╡ 2d175536-4fde-41ce-9645-33418d7ebc8f
# "v3saia---" # ὄρσε
string(getMorphology(pt9))

# ╔═╡ d7fbfa7e-69d8-4145-8f22-53c1bf3b3762
# "v-sfpmmn-" # λυσόμενός
string(getMorphology(pt10))

# ╔═╡ c6bec211-a726-4b14-b560-950566715a0b
# "g--------" # τε
string(getMorphology(pt11))

# ╔═╡ c92d5c39-2d8a-411e-8d2c-0cd36548c80b
# pt12 = "p-s---mg-" # οὗ
string(getMorphology(pt12))

# ╔═╡ ccdfcd41-4c13-4d2d-9ad5-856c7d8f6ecc
md"""
### Sandbox Below
"""

# ╔═╡ 425e219d-4af5-42c5-8348-7b59c73d529c
testMR = MorphRecord(posTag = "v", short = "vb", long = "verb")

# ╔═╡ cdf12645-000e-4dab-a757-18187c27c3f2
menin.tense == emptyMorphRecord

# ╔═╡ 9ef914d1-9a8f-4365-98ea-2fdae5fec819
begin

tmr1 = MorphRecord("", "", "", "")
tmr2 = emptyMorphRecord

#string(tmr1) == string(tmr2)

#isequal(tmr1, tmr2)

tmr1 == tmr2

	
	
end

# ╔═╡ 885c1c09-9afb-4867-9100-e927ca92fb58
tmr1.short = "x"

# ╔═╡ 26041c1a-325e-488c-8582-5bfd9f75517e
tmr1

# ╔═╡ 295d78d6-a243-47c3-ade9-eff9b485f348
isequal(tmr1, tmr2)

# ╔═╡ d93f5cea-7738-4792-abcc-1a61322d1eeb
tmr1.short = ""

# ╔═╡ 0859c5f7-94da-4d16-82d7-64f60e9186ce
isequal(tmr1, tmr2)

# ╔═╡ 721f64e6-aa39-4164-a7c4-086dde6c8bef
tm = deepcopy(emptyMorphRecord)

# ╔═╡ d56b22d0-72c0-4274-94fa-f71d2025325c
tm.short = "xxx"

# ╔═╡ a482360e-19b3-4669-a062-9a17ec3ccfb6
tm

# ╔═╡ 5f2f04f2-ae74-4b62-ac4c-fdb9e039587d
emptyMorphRecord

# ╔═╡ 7baac659-e0eb-4d51-bdb3-34eaf42d7542
numDict = Dict(

	"s" => MorphRecord("s", "sing", "singular", ""),
	"d" => MorphRecord("d", "dl", "dual", ""),
	"p" => MorphRecord("p", "pl", "plural", "")
	
)

# ╔═╡ 53adbe51-0098-443a-8166-fcd0bc5866dd
split(pt1, "")[voiceNum] |> string

# ╔═╡ 56ff0ab9-c909-4012-ac72-99a04476c592
Cite2Urn("urn:cite2:fuGreekMorph:pos.2022:article")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CitableBase = "d6f014bd-995c-41bd-9893-703339864534"
CitableCorpus = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
CitableObject = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
CitableText = "41e66566-473b-49d4-85b7-da83b66615d8"
EzXML = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
PolytonicGreek = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
SplitApplyCombine = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
Unicode = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[compat]
CitableBase = "~10.2.4"
CitableCorpus = "~0.12.6"
CitableObject = "~0.15.1"
CitableText = "~0.15.2"
EzXML = "~1.1.0"
PolytonicGreek = "~0.17.21"
SplitApplyCombine = "~1.2.2"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "155225ea8aaca8cb0083c2646cf7737f06bf3e2c"

[[deps.ANSIColoredPrinters]]
git-tree-sha1 = "574baf8110975760d391c710b6341da1afa48d8c"
uuid = "a4c015fc-c6ff-483c-b24f-f7ea428134e9"
version = "0.0.1"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BitFlags]]
git-tree-sha1 = "84259bb6172806304b9101094a7cc4bc6f56dbc6"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.5"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c5fd7cd27ac4aed0acf4b73948f0110ff2a854b2"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CitableBase]]
deps = ["DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "80afb8990f22cb3602aacce4c78f9300f67fdaae"
uuid = "d6f014bd-995c-41bd-9893-703339864534"
version = "10.2.4"

[[deps.CitableCorpus]]
deps = ["CitableBase", "CitableText", "CiteEXchange", "DocStringExtensions", "Documenter", "HTTP", "Tables", "Test"]
git-tree-sha1 = "a40fb467ba6d61e02f6aaf5c1d9147c869bfa17f"
uuid = "cf5ac11a-93ef-4a1a-97a3-f6af101603b5"
version = "0.12.6"

[[deps.CitableObject]]
deps = ["CitableBase", "CiteEXchange", "DocStringExtensions", "Documenter", "Downloads", "Test"]
git-tree-sha1 = "e147d2fa5fd4c036fd7b0ba0d14bf60d26dfefd2"
uuid = "e2b2f5ea-1cd8-4ce8-9b2b-05dad64c2a57"
version = "0.15.1"

[[deps.CitableText]]
deps = ["CitableBase", "DocStringExtensions", "Documenter", "Test"]
git-tree-sha1 = "87c096e67162faf21c0983a29396270cca168b4e"
uuid = "41e66566-473b-49d4-85b7-da83b66615d8"
version = "0.15.2"

[[deps.CiteEXchange]]
deps = ["CSV", "CitableBase", "DocStringExtensions", "Documenter", "HTTP", "Test"]
git-tree-sha1 = "8637a7520d7692d68cdebec69740d84e50da5750"
uuid = "e2e9ead3-1b6c-4e96-b95f-43e6ab899178"
version = "0.10.1"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DeepDiffs]]
git-tree-sha1 = "9824894295b62a6a4ab6adf1c7bf337b3a9ca34c"
uuid = "ab62b9b5-e342-54a8-a765-a90f495de1a6"
version = "1.2.0"

[[deps.Dictionaries]]
deps = ["Indexing", "Random", "Serialization"]
git-tree-sha1 = "e82c3c97b5b4ec111f3c1b55228cebc7510525a2"
uuid = "85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4"
version = "0.3.25"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Documenter]]
deps = ["ANSIColoredPrinters", "Base64", "Dates", "DocStringExtensions", "IOCapture", "InteractiveUtils", "JSON", "LibGit2", "Logging", "Markdown", "REPL", "Test", "Unicode"]
git-tree-sha1 = "6030186b00a38e9d0434518627426570aac2ef95"
uuid = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
version = "0.27.23"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "0fa3b52a04a4e210aeb1626def9c90df3ae65268"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.1.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "Dates", "IniFile", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "a97d47758e933cd5fe5ea181d178936a9fc60427"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.5.1"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.Indexing]]
git-tree-sha1 = "ce1566720fd6b19ff3411404d4b977acd4814f9f"
uuid = "313cdc1a-70c2-5d6a-ae34-0150d3930a38"
version = "1.1.1"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "a62189e59d33e1615feb7a48c0bea7c11e4dc61d"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "5d4d2d9904227b8bd66386c1138cf4d5ffa826bf"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "0.4.9"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "3c3c4a401d267b04942545b1e964a20279587fd7"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.3.0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e60321e3f2616584ff98f0a4f18d98ae6f89bbb3"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.17+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Orthography]]
deps = ["CitableBase", "CitableCorpus", "CitableText", "Compat", "DocStringExtensions", "Documenter", "OrderedCollections", "StatsBase", "Test", "TestSetExtensions", "TypedTables", "Unicode"]
git-tree-sha1 = "9d643f92145f36ad2284b5cb74281df1255712af"
uuid = "0b4c9448-09b0-4e78-95ea-3eb3328be36d"
version = "0.17.1"

[[deps.Parsers]]
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PolytonicGreek]]
deps = ["Compat", "DocStringExtensions", "Documenter", "Orthography", "Test", "TestSetExtensions", "Unicode"]
git-tree-sha1 = "4f5836914e6927f8094d04b1c1b25167bd7d839e"
uuid = "72b824a7-2b4a-40fa-944c-ac4f345dc63a"
version = "0.17.21"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "874e8867b33a00e784c8a7e4b60afe9e037b74e1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.1.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SplitApplyCombine]]
deps = ["Dictionaries", "Indexing"]
git-tree-sha1 = "48f393b0231516850e39f6c756970e7ca8b77045"
uuid = "03a91e81-4c3e-53e1-a0a4-9c0c8f19dd66"
version = "1.2.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TestSetExtensions]]
deps = ["DeepDiffs", "Distributed", "Test"]
git-tree-sha1 = "3a2919a78b04c29a1a57b05e1618e473162b15d0"
uuid = "98d24dd4-01ad-11ea-1b02-c9a08f80db04"
version = "2.0.0"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.TypedTables]]
deps = ["Adapt", "Dictionaries", "Indexing", "SplitApplyCombine", "Tables", "Unicode"]
git-tree-sha1 = "ec72e7a68a6ffdc507b751714ff3e84e09135d9e"
uuid = "9d95f2ec-7b3d-5a63-8d20-e2491e220bb9"
version = "1.4.1"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "58443b63fb7e465a8a7210828c91c08b92132dff"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.14+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═479731d6-56c7-11ed-3d83-37e9758cdc15
# ╠═541b8358-6627-4291-beae-ae7a9781cd1d
# ╠═e9c18ab6-a578-419e-a4ee-cd580e462190
# ╠═d622a77c-e757-4fc6-ae9f-8bcede5a8b79
# ╠═ec72dfd6-21dc-488d-8e07-3fdaec0fc71e
# ╠═8c53f66d-b34b-40ab-a018-c5e8f060c1b3
# ╠═4ae34040-4461-4449-aebc-7fd19a31075d
# ╟─01d07b3d-913d-4e17-86c2-a674c37075d3
# ╠═3ccd1d56-ae8d-403e-a607-dc8d5bf30fbf
# ╟─82b12b4b-0181-4c7f-909f-fa6e5b571eac
# ╠═75f46ebc-c630-48e2-806c-9b3f8d2a352d
# ╠═d9d5abfa-ece4-461d-afc2-9eed0be6ca11
# ╟─a5f682d3-310a-450f-b9d1-bec8e10ab1f9
# ╠═f308d263-7659-42ef-8f0d-5fff3eb7f46f
# ╟─6f551698-630e-4145-ac9e-4ef4f01872ad
# ╟─92844bb9-7a2e-4e43-920c-942ec9ccede8
# ╠═701abf20-ca37-443c-99e6-6b06368fc8db
# ╠═4d5bd156-1c82-4be2-bbff-06a82a03b9d2
# ╠═708af3d9-64fd-440c-9e21-68b11bccb6e2
# ╠═e469bce0-ee49-4d90-9ea1-3c4038d5a45b
# ╟─7c324144-b406-45e0-9cb4-288b7f46ab05
# ╟─ed5cca09-5623-4aab-a909-e371b47e086a
# ╠═911f1494-ca73-4ac0-9e90-b228ffc6080e
# ╠═d1fc518d-b93d-4e88-b849-f778911808f3
# ╠═8dafac49-daa3-407a-9f2a-1c083a0bef9e
# ╟─ebfed8d2-94c6-4865-889f-9b3e9239f0b4
# ╟─2dd0bb77-7e7d-4189-a7d2-674b221630c7
# ╠═da1c838b-510f-4c9e-8d11-1a6574ab3c3b
# ╠═062b19c9-4dcd-4784-bbd1-18df5de5a330
# ╠═92650cb0-447f-4669-900d-e9e298e8daa6
# ╟─fbc8bc36-c4fb-472a-8156-14c275622f94
# ╠═e34bf2d0-0f83-4dbc-b14a-87ae9ae47497
# ╠═e7a0413c-8eae-4df8-b67b-3742a1c3d3ab
# ╠═3c43456d-3db2-472a-9685-cabc0b704701
# ╠═88c31b4a-5197-40ef-95c7-e428796794b8
# ╠═96c14b07-a54b-4651-b554-225cada43ccb
# ╠═9bed6a4a-8714-46a1-94c9-8afccae03c58
# ╠═878bc6d4-02bc-4205-a6fe-92eb19264929
# ╠═dfc7f862-09af-41dc-a8f2-8c0724dc0056
# ╠═5d292d9c-3543-45be-a81a-928aa565717f
# ╠═2d175536-4fde-41ce-9645-33418d7ebc8f
# ╠═d7fbfa7e-69d8-4145-8f22-53c1bf3b3762
# ╠═c6bec211-a726-4b14-b560-950566715a0b
# ╠═c92d5c39-2d8a-411e-8d2c-0cd36548c80b
# ╟─ccdfcd41-4c13-4d2d-9ad5-856c7d8f6ecc
# ╠═425e219d-4af5-42c5-8348-7b59c73d529c
# ╠═cdf12645-000e-4dab-a757-18187c27c3f2
# ╠═9ef914d1-9a8f-4365-98ea-2fdae5fec819
# ╠═885c1c09-9afb-4867-9100-e927ca92fb58
# ╠═26041c1a-325e-488c-8582-5bfd9f75517e
# ╠═295d78d6-a243-47c3-ade9-eff9b485f348
# ╠═d93f5cea-7738-4792-abcc-1a61322d1eeb
# ╠═0859c5f7-94da-4d16-82d7-64f60e9186ce
# ╠═721f64e6-aa39-4164-a7c4-086dde6c8bef
# ╠═d56b22d0-72c0-4274-94fa-f71d2025325c
# ╠═a482360e-19b3-4669-a062-9a17ec3ccfb6
# ╠═5f2f04f2-ae74-4b62-ac4c-fdb9e039587d
# ╠═7baac659-e0eb-4d51-bdb3-34eaf42d7542
# ╠═53adbe51-0098-443a-8166-fcd0bc5866dd
# ╠═56ff0ab9-c909-4012-ac72-99a04476c592
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
