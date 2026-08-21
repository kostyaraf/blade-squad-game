"""Can the player actually walk from where an area starts to where it ends?

The converter cuts a 160-pixel band out of Solbrain's 256-pixel-tall rooms, and
a band that looks fine on a map can still be walled off floor-to-ceiling.  This
is a cheap platformer solver over the band's own collision grid: it stands the
player on the floor at the spawn and works out every metatile he can get to by
walking, falling and jumping.  It is deliberately generous -- it says yes to a
few jumps a real player would fluff -- because its job is to catch the places
that are flat-out impossible, not to grade the level.

The player is one metatile wide and two tall, jumps four metatiles up and
crosses five while airborne, which is about what Power Blade 2 gives him.
"""
JUMP_UP = 4
JUMP_ACROSS = 5


class Band:
    """One converted area's collision, as metatiles: `w` columns of `h` rows."""

    def __init__(self, solid, w, h):
        self.solid, self.w, self.h = solid, w, h

    def free(self, c, r):
        """Room for the player, who stands two metatiles tall."""
        return (0 <= c < self.w and 1 <= r < self.h
                and not self.solid(c, r) and not self.solid(c, r - 1))

    def grounded(self, c, r):
        """Standing on something.  The row below the last one is not floor --
        the area's collision simply stops there, so the player falls out of the
        level and dies, which is a pit and not a platform."""
        return self.free(c, r) and r + 1 < self.h and self.solid(c, r + 1)

    def fall(self, c, r):
        """Where the player ends up after stepping into (c, r).  None if he
        drops out of the band, which in Power Blade 2 means a pit."""
        while r < self.h:
            if not self.free(c, r):
                return None
            if self.grounded(c, r):
                return r
            r += 1
        return None

    def reachable(self, c0, r0):
        """Every standing spot the player can get to from (c0, r0)."""
        start = self.fall(c0, r0) if not self.grounded(c0, r0) else r0
        if start is None:
            return set()
        seen, stack = {(c0, start)}, [(c0, start)]
        while stack:
            c, r = stack.pop()
            for n in self._steps(c, r):
                if n not in seen:
                    seen.add(n)
                    stack.append(n)
        return seen

    def _steps(self, c, r):
        for d in (-1, 1):                       # walk off the edge, or along
            if self.free(c + d, r):
                nr = self.fall(c + d, r)
                if nr is not None:
                    yield (c + d, nr)
        for h in range(1, JUMP_UP + 1):         # jump: rise, drift, fall
            if not self.free(c, r - h):
                break
            for d in range(-JUMP_ACROSS, JUMP_ACROSS + 1):
                step = 1 if d > 0 else -1
                if any(not self.free(c + k * step, r - h)
                       for k in range(1, abs(d) + 1)):
                    continue
                nr = self.fall(c + d, r - h)
                if nr is not None:
                    yield (c + d, nr)
