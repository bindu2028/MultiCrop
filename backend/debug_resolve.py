from app import create_app


def run_resolve():
    app = create_app()
    with app.app_context():
        from app.services.compound_service import resolve_name

        # Test uncached
        print("=== TEST 1: Uncached Lookup (caffeine) ===")
        result = resolve_name("caffeine")
        print(f"cached: {result['cached']}")
        print(f"pubchem cid: {result['pubchem']['cid'] if result['pubchem'] else None}")
        if result['pubchem']:
            print(f"pubchem properties keys: {list(result['pubchem']['properties'].keys())}")
            print(f"pubchem synonyms count: {len(result['pubchem']['synonyms'])}")

        # Test cached
        print()
        print("=== TEST 2: Cached Lookup (caffeine again) ===")
        result2 = resolve_name("caffeine")
        print(f"cached: {result2['cached']}")
        print(f"pubchem cid: {result2['pubchem']['cid'] if result2['pubchem'] else None}")
        if result2['pubchem']:
            print(f"pubchem properties keys: {list(result2['pubchem']['properties'].keys())}")
            print(f"pubchem synonyms count: {len(result2['pubchem']['synonyms'])}")


if __name__ == '__main__':
    run_resolve()
