﻿namespace Rosetta.Lib.Validation
{
    using System;

    public interface IComparisonResult
    {
        bool Result { get; }

        bool EmptyOperand { get; }

        string Error { get; }

        IComparisonResult And(IComparisonResult comparisonResult);

        IComparisonResult AndIgnoreEmptyOperand(IComparisonResult comparisonResult);

        IComparisonResult Or(IComparisonResult comparisonResult);

        IComparisonResult OrIgnoreEmptyOperand(IComparisonResult comparisonResult);

    }

    public class ComparisonResult : IComparisonResult
    {
        public static ComparisonResult FromBoolean(bool? result)
        {
            return new ComparisonResult(result == true, false, null);
        }

        public static ComparisonResult Success()
        {
            return new ComparisonResult(true, false, null);
        }

        public static ComparisonResult SuccessEmptyOperand(string error)
        {
            return new ComparisonResult(true, true, error);
        }

        public static ComparisonResult Failure(string error)
        {
            return new ComparisonResult(false, false, error);
        }

        public static ComparisonResult FailureEmptyOperand(string error)
        {
            return new ComparisonResult(false, true, error);
        }

        public ComparisonResult(bool result, bool emptyOperand, string error)
        {
            Result = result;
            EmptyOperand = emptyOperand;
            Error = error;
        }

        public bool Result { get; private set; }

        public bool EmptyOperand { get; private set; }

        public string Error { get; private set; }

        public IComparisonResult And(IComparisonResult other)
        {
            return And(this, other);
        }

        private IComparisonResult And(IComparisonResult r1, IComparisonResult r2)
        {
            bool newResult = r1.Result && r2.Result;
            string newError = "";

            if (!r1.Result)
            {
                newError += r1.Error;
            }
            if (!r2.Result)
            {
                if (!r1.Result)
                {
                    newError += " and ";
                }
                newError += r2.Error;
            }
            return new ComparisonResult(newResult, false, newError);
        }

        public IComparisonResult AndIgnoreEmptyOperand(IComparisonResult comparisonResult)
        {
            return CombineIgnoreEmptyOperand(comparisonResult, And);
        }

        public IComparisonResult Or(IComparisonResult other)
        {
            return Or(this, other);
        }

        private IComparisonResult Or(IComparisonResult r1, IComparisonResult r2)
        {
            bool newResult = r1.Result || r2.Result;
            return new ComparisonResult(newResult, false, newResult ? null : $"{r1.Error} or {r2.Error}");
        }

        public IComparisonResult OrIgnoreEmptyOperand(IComparisonResult comparisonResult)
        {
            return CombineIgnoreEmptyOperand(comparisonResult, Or);
        }

        delegate IComparisonResult BooleanFunc(IComparisonResult comparisonResult);

        private IComparisonResult CombineIgnoreEmptyOperand(IComparisonResult other, BooleanFunc booleanFunc)
        {
            if (this.EmptyOperand && other.EmptyOperand)
            {
                return ComparisonResult.FailureEmptyOperand($"{this.Error} and {other.Error}");
            }
            if (this.EmptyOperand)
            {
                return other;
            }
            if (other.EmptyOperand)
            {
                return this;
            }
            return booleanFunc(other);
        }

    }
}
