from __future__ import annotations

from copy import deepcopy
from dataclasses import dataclass
from typing import Iterable

@dataclass
class BinaryFixedPoint:
    whole_bits: int = 16
    fraction_bits: int = 16
    _value: str = None

    def __post_init__(self) -> None:
        self.width = self.whole_bits + self.fraction_bits

    @property
    def value(self) -> str:
        return self._value[::-1]

    @value.setter
    def value(self, input_value: str) -> None:
        input_width = len(input_value)
        assert input_width == self.width, f'Value must have {self.width} bits but has {input_width}'
        for i, bit in enumerate(input_value):
            if bit not in ('0', '1'):
                raise ValueError('Binary string must contain only 0 and 1,'
                                 +f'but index {i} contains {bit}')

        self._value = input_value[::-1] # Store in reversed order to get big endian

    def __str__(self) -> str:
        return f'{self.value[:self.whole_bits]}.{self.value[-self.fraction_bits:]}'

    def __add__(self, other: BinaryFixedPoint) -> BinaryFixedPoint:
        assert (self.whole_bits == other.whole_bits
                and self.fraction_bits == other.fraction_bits)
        carry_in = 0
        new_value_list = []
        for i, bit in enumerate(self._value):
            value = int(bit)
            other_value = int(other._value[i])

            new_value = value ^ other_value ^ carry_in
            carry_out = (value & other_value) | ( (value ^ other_value) & carry_in)
            overflow = carry_in ^ carry_out
            carry_in = carry_out

            new_value_list.append(str(new_value))

        if overflow:
            raise ArithmeticError(f'Overflow occured when adding {self} and {other}')

        return self._from_iterator(reversed(new_value_list))

    def __mul__(self, other: BinaryFixedPoint) -> BinaryFixedPoint:
        if self._value[-1] == '1' or other._value[-1] == '1':
            raise ArithmeticError('Multiplication of negative numbers is not supported')

        def fill_to_double_width(value: str) -> BinaryFixedPoint:
            double_width = 2*self.width
            filled_value = (double_width - len(value))*'0' + value
            filled_binary = BinaryFixedPoint(whole_bits=double_width-self.fraction_bits,
                                             fraction_bits=self.fraction_bits)
            filled_binary.value = filled_value
            return filled_binary

        # tmp_result must have twice as many bits as operands
        # to avoid overflow during addition
        tmp_result = fill_to_double_width('0')
        # tmp_other follows to allow addition
        tmp_other = fill_to_double_width(other.value)

        for i, bit in enumerate(self._value):
            if bit == '1':
                tmp_result = tmp_result + (tmp_other << i)

        # Result shifted back to correct point position
        tmp_result = tmp_result >> self.fraction_bits
        # The sign bit or those after it are non-zero iff overflow happened
        if '1' in tmp_result._value[self.width-1:]:
            raise ArithmeticError(f'Overflow occured when multiplying {self} and {other}')

        # Remove bits after self.width -- they are all be zero
        result = self._from_iterator(reversed(tmp_result._value[:self.width]))
        return result

    def __invert__(self) -> BinaryFixedPoint:
        new_bit_list = []
        for bit in self.value:
            new_bit = '0' if bit == '1' else '1' # Python ~ operator does not turn 0 into 1
            new_bit_list.append(new_bit)
        return self._from_iterator(new_bit_list)

    def __neg__(self) -> BinaryFixedPoint:
        one = BinaryFixedPoint(self.whole_bits, self.fraction_bits)
        one.value = ['0']*(self.width-1) + ['1']
        return ~self + one

    def __sub__(self, other: BinaryFixedPoint) -> BinaryFixedPoint:
        return self + (-other)

    def __rshift__(self, other: int) -> BinaryFixedPoint:
        if other == 0:
            return deepcopy(self)
        return self._from_iterator(other*self.value[0] + self.value[:-other])

    def __lshift__(self, other: int) -> BinaryFixedPoint:
        if other == 0:
            return deepcopy(self)
        return self._from_iterator(self.value[other:] +other*'0')

    def _from_iterator(self, iterator: Iterable[str]) -> BinaryFixedPoint:
        """Return a BinaryFixedPoint instance with the same
        number of whole and fractional bits as self and value
        set by the iterator."""
        return BinaryFixedPoint.from_iterator(iterator,
                                              whole_bits=self.whole_bits,
                                              fraction_bits=self.fraction_bits)

    @staticmethod
    def from_iterator(iterator: Iterable[str],
                      whole_bits: int = 16,
                      fraction_bits: int = 16) -> BinaryFixedPoint:
        bit_vector = ''.join(iterator)
        return BinaryFixedPoint.from_bit_vector(bit_vector,
                                                whole_bits, fraction_bits)

    @staticmethod
    def from_bit_vector(bit_vector: str,
                        whole_bits: int = 16,
                        fraction_bits: int = 16) -> BinaryFixedPoint:
        obj = BinaryFixedPoint(whole_bits, fraction_bits)
        obj.value = bit_vector
        return obj


if __name__ == '__main__':
    test_vector = ['1']*5 + ['0']*20 + ['1']*7
    test_obj = BinaryFixedPoint.from_iterator(test_vector)
    print(test_obj.value)
    print(test_obj)

    test_one = BinaryFixedPoint(whole_bits=4, fraction_bits=4)
    test_one.value = '00000001'
    print(test_one)
    two = BinaryFixedPoint(whole_bits=4, fraction_bits=4)
    two.value = '00000010'
    print(two)
    six = BinaryFixedPoint(whole_bits=4, fraction_bits=4)
    six.value = '00000110'
    print(six)
    c = test_one + six
    print(c)

    print('\n')
    print(c)
    print(~c)
    print(-c)

    print('\n')
    print(six-test_one)
    print(test_one-six)

    print('\n')
    print(six << 0)
    print(six << 1)
    print(six >> 0)
    print(six >> 1)
    print(test_one-six << 1)
    print(test_one-six >> 1)

    print('\n')
    actual_one = BinaryFixedPoint.from_bit_vector('00010000', # 1
                                                  whole_bits=4,
                                                  fraction_bits=4)
    actual_one_half = BinaryFixedPoint.from_bit_vector('00001000', # 0.5
                                                       whole_bits=4,
                                                       fraction_bits=4)
    actual_three = BinaryFixedPoint.from_bit_vector('00110000', # 3
                                                    whole_bits=4,
                                                    fraction_bits=4)

    print(actual_one * actual_one_half)
    # ArithmeticError expected: trying to fit 9 into a 4-bit signed number
    print(actual_three * actual_three)
