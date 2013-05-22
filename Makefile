test:
	amxmlc -warnings=true -use-network=true -compiler.strict=true -compiler.show-binding-warnings=true -compiler.show-deprecation-warnings=true -compiler.debug=true --source-path ./src -- ./src/SemVerTest.as
	cd src && adl tests.xml