﻿#nullable enable // Allow nullable reference types

namespace Org.Isda.Cdm.Functions
{
    using System.Collections.Generic;
    using System.Linq;

    using Org.Isda.Cdm;
    using Org.Isda.Cdm.MetaFields;
    using Rosetta.Lib.Functions;

    // TEMPORARY: Should be generated
    public class ForwardFX : IRosettaFunction
    {
        static public ForeignExchange Evaluate(ForwardPayout forwardPayout)
        {
            var fx =  forwardPayout.Underlier.UnderlyingProduct.ForeignExchange;
            if (fx == null)
            {
                // TODO: Define ValidationException
                throw new System.Exception($"ForeignExchange is not specified on {forwardPayout}");
            }
            return fx;
        }
    }

    public class FpmlIrd8 : IRosettaFunction
    {
        static public bool Evaluate(TradableProduct tradableProduct, IEnumerable<Account> accounts)
        {
            if (tradableProduct.Counterparties.Count() != 2)
                return false;

            var parties = tradableProduct.Counterparties.ToArray();
            ReferenceWithMetaParty? party1 = parties[0].PartyReference;
            ReferenceWithMetaParty? party2 = parties[1].PartyReference;

            if (party1 == null || party2 == null)
                return false;

            if (!party1.Equals(party2))
                return true;

            // Same party on each side of trade, so accounts must different
            return accounts.Count(a => party1.Equals(a.PartyReference)) == 2;
        }
    }

    public class Sum : IRosettaFunction
    {
        static public double Evaluate(IEnumerable<double> values)
        {
            return values.Sum();
        }
        static public decimal Evaluate(IEnumerable<decimal> values)
        {
            return values.Sum();
        }
    }

    // TEMPORARY: Should be generated
    public class PriceQuantityTriangulation : IRosettaFunction
    {
        static public bool Evaluate(IEnumerable<PriceNotation> priceNotation, IEnumerable<QuantityNotation> quantityNotation)
        {
            return true;
        }
    }

}
