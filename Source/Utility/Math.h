/*
 Copyright (C) 2010-2012 Kristian Duske

 This file is part of TrenchBroom.

 TrenchBroom is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 TrenchBroom is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with TrenchBroom.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef TrenchBroom_Math_h
#define TrenchBroom_Math_h

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <limits>

namespace TrenchBroom {
    namespace Math {
        static const float AlmostZero = 0.001f;
        static const float PointStatusEpsilon = 0.01f;
        static const float CorrectEpsilon = 0.001f; // this is what QBSP uses
        static const float ColinearEpsilon = 0.01f;
        static const float Pi = 3.141592f;

        inline bool isnan(float f) {
#ifdef _MSC_VER
            return _isnan(f) != 0;
#else
            return std::isnan(f);
#endif
        }

        inline float nan() {
            return std::numeric_limits<float>::quiet_NaN();
        }

        inline float radians(float d) {
            return Pi * d / 180.0f;
        }

        inline float degrees(float r) {
            return 180.0f * r / Pi;
        }

        inline float round(float f) {
            return f > 0.0f ? std::floor(f + 0.5f) : std::ceil(f - 0.5f);
        }

        inline float correct(float f, float epsilon = CorrectEpsilon) {
            const float r = round(f);
            if (std::abs(f - r) <= epsilon
                )
                return r;
            return f;
        }

        inline bool zero(float f, float epsilon = AlmostZero) {
            return std::abs(f) <= epsilon;
        }

        inline bool pos(float f, float epsilon = AlmostZero) {
            return f > epsilon;
        }

        inline bool neg(float f, float epsilon = AlmostZero) {
            return f < -epsilon;
        }

        inline bool relEq(float f1, float f2, float epsilon = AlmostZero) {
            const float absA = std::abs(f1);
            const float absB = std::abs(f2);
            const float diff = std::abs(f1 - f2);
            
            if (f1 == f2) { // shortcut, handles infinities
                return true;
            } else if (f1 == 0.0f || f2 == 0.0f || diff < std::numeric_limits<float>::min()) {
                // a or b is zero or both are extremely close to it
                // relative error is less meaningful here
                return diff < (epsilon * std::numeric_limits<float>::min());
            } else { // use relative error
                return diff / (absA + absB) < epsilon;
            }
        }

        inline bool eq(float f1, float f2, float epsilon = AlmostZero) {
            return std::abs(f1 - f2) < epsilon;
        }

        inline bool gt(float f1, float f2, float epsilon = AlmostZero) {
            return f1 > f2 + epsilon;
        }

        inline bool lt(float f1, float f2, float epsilon = AlmostZero) {
            return f1 < f2 - epsilon;
        }

        inline bool gte(float f1, float f2, float epsilon = AlmostZero) {
            return !lt(f1, f2, epsilon);
        }

        inline bool lte(float f1, float f2, float epsilon = AlmostZero) {
            return !gt(f1, f2, epsilon);
        }

        inline bool between(float f, float s, float e, float epsilon = AlmostZero) {
            if (eq(f, s, epsilon) || eq(f, e, epsilon))
                return true;
            if (lt(s, e, epsilon))
                return gt(f, s, epsilon) && lt(f, e, epsilon);
            return gt(f, e, epsilon) && lt(f, s, epsilon);
        }
        
        inline float selectMin(float f1, float f2) {
            if (isnan(f1))
                return f2;
            if (isnan(f2))
                return f1;
            return std::min(f1, f2);
        }
        
        inline size_t succ(size_t index, size_t count, size_t offset = 1) {
            return (index + offset) % count;
        }

        inline size_t pred(size_t index, size_t count, size_t offset = 1) {
            return ((index + count) - (offset % count)) % count;
        }

		namespace Axis {
			typedef unsigned int Type;
			static const Type AX = 0;
			static const Type AY = 1;
			static const Type AZ = 2;
		}

        typedef enum {
            DUp,
            DRight,
            DDown,
            DLeft,
            DForward,
            DBackward
        } Direction;

		namespace PointStatus {
			typedef unsigned int Type;
			static const Type PSAbove = 0;
			static const Type PSBelow = 1;
			static const Type PSInside = 2;
		}
    }
}

#endif
